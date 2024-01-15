## Artifacts

The code in this folder can be used to:

1. Retrieve data from the original paper [repo](https://github.com/gtfintechlab/fomc-hawkish-dovish).
2. Pre-process the data.
3. Store data as package artifacts to make them easily accessible and version-controlled.

> [!NOTE]  
> The project in this folder depends on this dev [version](https://github.com/pat-alt/ArtifactUtils.jl) of `ArtifactUtils.jl`. To upload artifacts, the `GITHUB_TOKEN` needs to be available from the shell environment.

### Rerun Step 2 and 3

To simply rerun steps 2 and 3, just run `julia --project=dev dev/src/prepare_all_artifacts.jl`.

### Rerun All Steps

To rerun all steps, just run `julia --project=dev dev/src/prepare_all_artifacts.jl -- overwrite`.