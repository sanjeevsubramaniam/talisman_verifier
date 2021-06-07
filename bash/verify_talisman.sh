#!/usr/bin/env bash
VALID_GIT_REPOS=()
INVALID_GIT_REPOS=()
PATHS_TO_VERIFY=()


function hasGit {
	git --version > /dev/null 2>&1
	if [ $? -eq 0 ]; then
		echo "Great you have git...!!!"
		echo "Let me check on talisman."
	else
		echo "You have not yet installed git, Run me again once you have git installed and some git repositories."
	fi
}

function collectSubDirectories {
	PWD=`pwd`
	for f in *; do
		if [[ -d "$f" && ! -L "$f" && ! -z "$f" ]]; then
			DIR_PATH=$PWD
			DIR_PATH+="/"
			DIR_PATH+=$f
			PATHS_TO_VERIFY+=($DIR_PATH)
		fi
	done
}

function verifyTalisman {
	DIRECTORY=$1
	git stash > /dev/null 2>&1
	echo 'password: 9oikjmnbvfrt678uikmnbvgt' >> talisman_check.yml
	git add talisman_check.yml > /dev/null 2>&1
	git commit -m 'check talisman' > /dev/null 2>&1
	if [ $? -eq 0 ]; then
		INVALID_GIT_REPOS+=($DIRECTORY)
		git reset --hard HEAD~1 > /dev/null 2>&1
	else
		VALID_GIT_REPOS+=($DIRECTORY)
		git reset HEAD talisman_check.yml > /dev/null 2>&1
		rm -f talisman_check.yml
	fi
	git stash pop > /dev/null 2>&1
}

function isGitRepo {
	DIRECTORY=$1
	git status > /dev/null 2>&1
	if [ $? -eq 0 ]; then
		echo "$DIRECTORY is a git repo, checking talisman..."
		verifyTalisman $DIRECTORY
	else
		echo "$DIRECTORY is not a git repo"
		collectSubDirectories $DIRECTORY
	fi
}

function validateVerificationRoot {
	VERIFICATION_ROOT=$1
	echo "Checking path $VERIFICATION_ROOT"
	cd $VERIFICATION_ROOT > /dev/null 2>&1
	if [ $? -eq 0 ]; then
		isGitRepo $VERIFICATION_ROOT
	else
		echo "\n$VERIFICATION_ROOT is not found"
	fi
}

function display {
	RED="\033[0;31m"
	GREEN="\033[0;32m"
	ENDCOLOR='\033[0m'
	echo -e "${GREEN}\nRepos with Proper talisman setup:"
	echo -e "${VALID_GIT_REPOS[@]}" | tr ' ' '\n'
	echo -e "${RED}\nRepos where talisman not working:"
	echo -e "${INVALID_GIT_REPOS[@]}" | tr ' ' '\n'
	echo -e "${ENDCOLOR} \n\nDone!!!"
}

function usage {
	light_red='\033[1;31m'
	no_color='\033[0m'
	echo -e "usage: ./verify_talisman.sh <path>"
	echo -e "\nverify_talisman is a simple tool that recursively check the given paths to find git repositories and verify whether talisman pre-commit hook is functioning or not. It checks all the directores and lists out in which repos the setup is working and the ones in which the setup is not working."
	echo -e "${light_red}\nWarning: The tool will try to make a commit and revert it. Make sure that commits can be made in all the repos."
	echo -e "${no_color}\nexample: ./verify_talisman.sh ~/Documents/work_repos ~/Documents/open_source_contributions"

}

if [ $# -lt 1 ]; then
	usage
	exit 1
fi
hasGit
PATHS_TO_VERIFY+=("$@")
INDEX=0
while [ "$INDEX" -lt ${#PATHS_TO_VERIFY[@]} ] 
do
	DIR=${PATHS_TO_VERIFY[$INDEX]}
	validateVerificationRoot $DIR
	INDEX=$((INDEX+1))
done
display



