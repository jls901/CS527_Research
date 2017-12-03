$rootTestDir="D:/UIUC-GIT"
$tiaGitSolutionDirectory="$rootTestDir/TestProjectSourceVSTS/Accord.NET"
$gitHubSolutionDirectory="$rootTestDir/TestProjectsGitHubSourceTIA/framework"
$gitHubDirectory="$rootTestDir/TestProjectsGitHubSourceTIA"
$gitHubSrcURI="https://github.com/accord-net/framework.git"
$commitToAnalyze=350
$numberOfCommitsToAnalyze=1

function CloneGitRepo {
    param([string] $gitURI, [string] $gitSrcDir)
    $projectCloned = Test-Path $gitHubSolutionDirectory 
    if (-Not $projectCloned) {
        echo "Cloning the project under test git repo"
        git clone $gitURI "$gitSrcDir"
    }
}

function ResetGitRepo {
    git fetch origin
    git reset --hard origin/master
    git clean -xdff -e **/*/storage.ide
}

function CommitVSTSGitChanges {
    param([string] $msg)
    git add -A
    git commit -m $msg
}

function PushVSTSGitChanges {
    param([string] $msg)
    $workingDir = pwd
    cd $tiaGitSolutionDirectory
    CommitVSTSGitChanges -msg $msg
    git push
    cd $workingDir
}

function ReverGitRepoXNumberOfCommintsBack {
    param([string] $gitRepoPath, [int] $numberOfCommitsBack)
    $workingDir = pwd
    cd $gitRepoPath
    ResetGitRepo
    git reset --hard HEAD~$numberOfCommitsBack
    git clean -xdff -e **/*/storage.ide
    git submodule init
    git submodule update
    cd $workingDir
} 

function CleanVSTSDirectory {
    $vstsFolderExists = Test-Path $tiaGitSolutionDirectory 
    if ($vstsFolderExists) {
        Get-ChildItem -Path  $tiaGitSolutionDirectory -Recurse  |
        Select -ExpandProperty FullName |
        Where {$_ -notlike '*TestAdaptors*'} |
        sort-object length -Descending |
        Remove-Item -Force -Recurse 
    }
}

function CopyGitHubSrcToVSTSGitRepo {
    # rsync -rvu -I -P --chmod=Fo=rwx,Fg=rwx $gitHubSolutionDirectory/* $tiaGitSolutionDirectory
     xcopy $gitHubSolutionDirectory $tiaGitSolutionDirectory 
}

CloneGitRepo -gitURI $gitHubSrcURI -gitSrcDir $gitHubSolutionDirectory 

$numberOfCommitsLeft=$numberOfCommitsToAnalyze
while ($numberOfCommitsLeft -gt 0) {
    #Checkout git commit i commits ago
    $currentCommit=$commitToAnalyze-($numberOfCommitsToAnalyze - $numberOfCommitsLeft)
    ReverGitRepoXNumberOfCommintsBack -gitRepoPath $gitHubSolutionDirectory -numberOfCommitsBack $currentCommit

    #Clean the VSTS git directory to copy into
    CleanVSTSDirectory

    #Copy the Source GitHub Repo to VSTS Git Repo
     CopyGitHubSrcToVSTSGitRepo

    #Push the new changeset to VSTS
     PushVSTSGitChanges -m "$currentCommit commits back from current GitHub head"

     $numberOfCommitsLeft -= 1
     Start-Sleep -s 30
}