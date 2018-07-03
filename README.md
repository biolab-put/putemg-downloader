# putemg-downloader
Download scripts for putEMG dataset.
For dataset description and terms of use, please see http://biolab.put.poznan.pl/putemg-dataset/

# Usage

Arguments are identical for both bash and Python versions. Python version also checks selected ID availability, bash just skips unavailable IDs. Bash version requires wget.

```shell
putemg_downloader.sh <experiment_type> <media_type> [<id1> <id2> ...]
putemg_downloader.py <experiment_type> <media_type> [<id1> <id2> ...]
```
Arguments:

`<experiment_type>` comma-separated list of experiment types (supported types: emg_gestures, emg_force)
    
`<media_type>` comma-separated list of media (supported types: data-csv, data-hdf5, depth, video-1080p, video-576p)
    
`[<id1> <id2> ...]` optional list of two-digit participant IDs, fetches all if none are given

# Examples

Download gesture EMG data for all participants in HDF5 format, along with 1080p RGB videos:
```shell
putemg_downloader.sh emg_gestures data-hdf5,video-1080p
```

Download both gesture and force EMG data in CSV format, for participant IDs 03, 04, and 07 along with depth PNG images :
```shell
putemg_downloader.sh emg_gestures,emg_force data-csv,depth 03 04 07
```
