# talisman_verifier

## About:

verify_talisman is a simple tool that recursively check the given paths to find git repositories and verify whether talisman pre-commit hook is functioning or not. It checks all the directores and lists out in which repos the setup is working and the ones in which the setup is not working.

## Warning:

 The tool will try to make a commit and revert it. Make sure that commits can be made in all the repos.

## Example: 

`./verify_talisman.sh ~/Documents/work_repos ~/Documents/open_source_contributions`
