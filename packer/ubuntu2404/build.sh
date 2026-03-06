packer build -force -on-error=ask \
    -var-file="ubuntu2404.pkrvars.hcl" \
    -var-file="vsphere.pkrvars.hcl" \
    .