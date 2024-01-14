using Artifacts, ArtifactUtils
import CodecZlib, Downloads, Tar

# Raw data folder:
raw_data_dir = "dev/data/fomc-hawkish-dovish-main/data"

if !isdir(raw_data_dir)
    tgz = Downloads.download("https://github.com/gtfintechlab/fomc-hawkish-dovish/archive/refs/heads/main.tar.gz")
    open(GzipDecompressorStream, tgz) do io
        Tar.extract(
            x -> contains(x.path, "fomc-hawkish-dovish-main/data"), 
            io, "dev/data"
        )
    end
end