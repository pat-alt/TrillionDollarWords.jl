## Artifacts

The code in this folder can be used to:

1. Retrieve data from the original paper [repo](https://github.com/gtfintechlab/fomc-hawkish-dovish).
2. Pre-process the data.
3. Store data as package artifacts to make them easily accessible and version-controlled.


### Rerun Step 2 and 3

To simply rerun steps 2 and 3, just run `julia --project=dev dev/prepare_all_artifacts.jl`.

### Rerun All Steps

To rerun all steps, just run `julia --project=dev dev/prepare_all_artifacts.jl -- overwrite`.