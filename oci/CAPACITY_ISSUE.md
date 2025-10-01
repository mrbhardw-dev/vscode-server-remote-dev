# OCI Capacity Issue - Out of Host Capacity

## Problem
```
Error: 500-InternalError, Out of host capacity.
```

This error occurs when OCI doesn't have available ARM (A1.Flex) instances in your selected region. ARM instances are in high demand for the Always Free tier.

## Solutions

### Option 1: Try a Different Region

ARM capacity varies by region. Try these regions (in order of likelihood):

1. **us-phoenix-1** (Phoenix, Arizona) - Usually has good capacity
2. **us-ashburn-1** (Ashburn, Virginia) - Good capacity
3. **eu-frankfurt-1** (Frankfurt, Germany) - Moderate capacity
4. **ap-seoul-1** (Seoul, South Korea) - Good capacity

**To change region:**

Edit your `terraform.tfvars` file:
```hcl
region = "us-phoenix-1"  # Change from uk-london-1
```

Then run:
```bash
terraform destroy  # Clean up existing resources
terraform apply    # Try in new region
```

### Option 2: Use AMD Instance (Immediate Solution)

Switch to AMD-based Always Free instance (always available):

Edit your `terraform.tfvars` file:
```hcl
instance_shape = "VM.Standard.E2.1.Micro"
# Comment out or remove these lines:
# instance_ocpus = 2
# instance_memory_in_gbs = 12
```

**Specs:**
- 1 OCPU (AMD)
- 1 GB RAM
- 50 GB storage
- You can run 2 of these instances

Then run:
```bash
terraform apply
```

### Option 3: Retry Later (Wait for Capacity)

ARM capacity fluctuates. You can:

1. **Retry every few hours** - Capacity often becomes available
2. **Try during off-peak hours** - Early morning UTC often has better capacity
3. **Use a retry script**:

```bash
#!/bin/bash
# retry-terraform.sh
while true; do
    echo "Attempting to create instance..."
    terraform apply -auto-approve
    if [ $? -eq 0 ]; then
        echo "Success!"
        break
    fi
    echo "Failed. Retrying in 5 minutes..."
    sleep 300
done
```

### Option 4: Try Multiple Regions with Script

Create a script to try multiple regions automatically:

```bash
#!/bin/bash
# try-regions.sh
REGIONS=("us-phoenix-1" "us-ashburn-1" "eu-frankfurt-1" "ap-seoul-1" "uk-london-1")

for region in "${REGIONS[@]}"; do
    echo "Trying region: $region"
    
    # Update terraform.tfvars
    sed -i "s/^region = .*/region = \"$region\"/" terraform.tfvars
    
    # Try to apply
    terraform apply -auto-approve
    
    if [ $? -eq 0 ]; then
        echo "Successfully deployed in $region!"
        exit 0
    fi
    
    echo "Failed in $region, trying next..."
    terraform destroy -auto-approve
done

echo "All regions exhausted. Try again later."
```

## Recommended Approach

### Quick Solution (AMD):
```bash
# Edit terraform.tfvars
nano terraform.tfvars

# Change to:
instance_shape = "VM.Standard.E2.1.Micro"

# Apply
terraform apply
```

### Best Solution (ARM in different region):
```bash
# Destroy current resources
terraform destroy

# Edit terraform.tfvars
nano terraform.tfvars

# Change region to:
region = "us-phoenix-1"

# Apply
terraform apply
```

## Why This Happens

1. **High Demand**: ARM instances are very popular (better performance, free)
2. **Limited Free Tier Capacity**: OCI limits Always Free resources per region
3. **Regional Variations**: Some regions have more capacity than others
4. **Time-based**: Capacity fluctuates throughout the day

## Current Status

- **Your Region**: uk-london-1
- **Instance Type**: VM.Standard.A1.Flex (ARM)
- **Status**: Out of capacity

## Next Steps

1. **Immediate**: Switch to AMD instance (Option 2)
2. **Later**: Try ARM in us-phoenix-1 (Option 1)
3. **Patient**: Retry uk-london-1 during off-peak hours (Option 3)

## Additional Resources

- [OCI Free Tier](https://docs.oracle.com/en-us/iaas/Content/FreeTier/freetier.htm)
- [OCI Regions](https://docs.oracle.com/en-us/iaas/Content/General/Concepts/regions.htm)
- [Capacity Issues](https://docs.oracle.com/en-us/iaas/Content/Compute/References/computeshapes.htm)
