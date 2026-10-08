#!bin/sh

REPOSITORY="git@github.com:koba-masa/play_with_github.git"
REPOSITORY_NAME="play_with_github_tmp"
WORK_DIR="tmp"


function delete_work_repository() {
  if [ -d ${WORK_DIR}/${REPOSITORY_NAME} ]; then
    rm -rf ${WORK_DIR}/${REPOSITORY_NAME}
  fi
}

function clone_repository() {
  git clone ${REPOSITORY} ${WORK_DIR}/${REPOSITORY_NAME}
}

function commit() {
  local pattern=$1
  local branch=$2
  local commit_message=$3
  local number_of_attempts=$4
  local file_id=$5
  local commit_message_suffix=""
  if [ ${number_of_attempts} -gt 0 ]; then
    commit_message_suffix=" (${number_of_attempts}回目)"
  fi
  local file_path="${WORK_DIR}/stacked_pr_verification_${file_id}.log"

  # 存在しない場合はブランチを作成する
  if [ -z "$(git branch --list ${branch})" ]; then
    git branch ${branch}
  fi
  git checkout ${branch}
  echo "${branch}: ${commit_message}" >> ${file_path}
  git add ${file_path}
  git commit -m "[STACKED PR VERIFICATION][PATTERN: ${pattern}] ${branch}: ${commit_message} ${commit_message_suffix}"
  git push origin ${branch}
}

trunk_branch="main"
number_of_attempts=0
base_dir=`pwd`

if [ $# -gt 2 ]; then
  echo "Usage: $0 {trunk_branch} {number_of_attempts}"
  exit 1
fi

if [ $# -eq 1 ]; then
  if [ -n "$1" ] && [ -z "$(echo "$1" | sed 's/[0-9]//g')" ]; then
    number_of_attempts=$1
  else
    trunk_branch=$1
  fi
elif [ $# -eq 2 ]; then
    trunk_branch=$1
    number_of_attempts=$2
fi

echo "trunk_branch:       ${trunk_branch}"
echo "number_of_attempts: ${number_of_attempts}"

read -p "Are you sure? (y/n): " confirm
if [ "$confirm" != "y" ]; then
  echo "Aborting..."
  exit 1
fi

delete_work_dir
clone_repository
cd ${WORK_DIR}/${REPOSITORY_NAME}
git checkout ${trunk_branch}

pattern=1

if [ "${trunk_branch}" != "main" ]; then
  commit "${pattern}" "${trunk_branch}" "commit A" "${number_of_attempts}" "001"
  commit "${pattern}" "${trunk_branch}" "commit B" "${number_of_attempts}" "002"
fi

commit "${pattern}" "feature1" "commit C" "${number_of_attempts}" "003"
commit "${pattern}" "feature1" "commit D" "${number_of_attempts}" "004"

commit "${pattern}" "feature2" "commit E" "${number_of_attempts}" "005"
commit "${pattern}" "feature1" "commit F" "${number_of_attempts}" "006"
commit "${pattern}" "feature2" "commit G" "${number_of_attempts}" "007"
commit "${pattern}" "feature3" "commit H" "${number_of_attempts}" "008"

#cd ${base_dir}
