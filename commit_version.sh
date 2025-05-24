#!/bin/bash

# Pregunta por el mensaje de commit
read -p "Mensaje del commit: " msg

# Incrementa la versión en pubspec.yaml (solo patch, puedes modificarlo para mayor o minor)
version_line=$(grep 'version: ' pubspec.yaml)
current_version=$(echo $version_line | awk '{print $2}')
IFS='+' read -r semver build <<< "$current_version"
IFS='.' read -r major minor patch <<< "$semver"
new_patch=$((patch + 1))
new_version="$major.$minor.$new_patch+$build"

# Reemplaza la versión en pubspec.yaml
sed -i.bak "s/version: .*/version: $new_version/" pubspec.yaml
rm pubspec.yaml.bak

# Agrega, hace commit y push
git add .
git commit -m "$msg"
git push

echo "✅ Commit hecho con versión: $new_version"
