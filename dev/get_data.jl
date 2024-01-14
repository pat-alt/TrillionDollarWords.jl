using Artifacts, ArtifactUtils
import CodecZlib, Downloads, Tar

# Raw data folder:
raw_data_root = "dev/data/raw"
raw_data_dir = joinpath(raw_data_root, "fomc-hawkish-dovish-main/data")
OVERWRITE = true

if !isdir(raw_data_dir) || OVERWRITE
    if isdir(raw_data_root)
        rm(raw_data_root; recursive=true)
    end
    tgz = Downloads.download("https://github.com/gtfintechlab/fomc-hawkish-dovish/archive/refs/heads/main.tar.gz")
    open(GzipDecompressorStream, tgz) do io
        Tar.extract(
            x -> contains(x.path, "fomc-hawkish-dovish-main/data") || contains(x.path, "training_data"), 
            io, "dev/data/raw"
        )
    end
end