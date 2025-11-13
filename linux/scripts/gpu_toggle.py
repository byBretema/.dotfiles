# Lovingly typ(o)ed @byBretema


################################################################################

FILEPATH = "/etc/environment"

PARAMS = [
    "__NV_PRIME_RENDER_OFFLOAD=1",
    "__GLX_VENDOR_LIBRARY_NAME=nvidia",
    "__VK_LAYER_NV_optimus=NVIDIA_only",
    "VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/nvidia_icd.json",
]


################################################################################
def gpu_toggle():

    out: str = "\n"
    visited = set()

    first: bool = False

    with open(FILEPATH, "r") as f:
        for line in iter(f.readline, ""):

            # Process params: Toggle comments
            for param in PARAMS:
                if param in line:
                    prefix = "" if line.strip().startswith("#") else "# "
                    if not first:
                        out += "\n"
                        first = True
                    out += f"{prefix}{param}\n"
                    visited.add(param)
                    break  # <-- param found, go to next line

            # Process non-params: No changes
            else:
                if line.strip():
                    out += line

    # If not visited add it to the file
    for param in PARAMS:
        if param not in visited:
            out += f"{param}\n"

    # Write back to the file
    with open(FILEPATH, "w") as file:
        file.write(out)

    # Show results and instructions
    print("- " * 40)
    print(out)
    print("- " * 40)
    print("\n@ Remeber to re-login to apply the changes !")


################################################################################
if __name__ == "__main__":
    gpu_toggle()
