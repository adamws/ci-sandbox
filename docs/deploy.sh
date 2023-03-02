#!/bin/sh

set -o nounset
set -o errexit

# Build and deploy documentation

# install and build
echo "==> Dependencies install\n"
npm install

echo "==> Build\n"
npm run build

echo "==> Configure git\n"
git config user.name "CircleCI"
git config user.email "${CIRCLE_PROJECT_USERNAME}@users.noreply.github.com"

echo "==> Prepare to deploy\n"

# navigate into the build output directory
cd src/.vuepress

git clone --depth=1 --single-branch --branch gh-pages $CIRCLE_REPOSITORY_URL gh-pages
cd gh-pages

if [ -z "$(git status --porcelain)" ]; then
    echo "Something went wrong" && \
    echo "Exiting..."
    exit 0
fi

# remove everything except "release" directory
git rm -rf .
git checkout HEAD -- relase || true

# move fresh build to repository
cp -r ../dist .

mkdir .circleci
wget https://raw.githubusercontent.com/adamws/keyboard-tools/master/.circleci/ghpages-config.yml -O .circleci/config.yml
touch .nojekyll

echo "==> Start deploying"
git add -A
git commit -m "Deploy documentation: ${CIRCLE_SHA1}"

git push

rm -fr .git

echo "==> Deploy succeeded"
