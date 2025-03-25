# Add essential Flutter project files to git
$essentialFiles = @(
    ".gitignore",
    "lib/*",
    "pubspec.yaml",
    "analysis_options.yaml",
    "README.md",
    "android/app/src/*",
    "android/app/build.gradle",
    "android/build.gradle",
    "ios/Runner/*",
    "assets/*",
    ".metadata",
    "test/*"
)

# Add each file/directory
foreach ($file in $essentialFiles) {
    Write-Host "Adding $file..."
    git add $file
}

# Show status
Write-Host "`nGit Status:"
git status 