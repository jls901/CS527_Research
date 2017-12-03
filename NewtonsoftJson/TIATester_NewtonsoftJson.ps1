$tiaGitSolutionDirectory="D:\UIUC-GIT\TestProjecSourceVSTS\Newtonsoft.Json"
$gitHubSolutionDirectory="D:\UIUC-GIT\TestProjectsGitHubSourceTIA\Newtonsoft.Json"
$gitHubDirectory="D:\UIUC-GIT\TestProjectsGitHubSourceTIA"
$gitHubSrcURI="https://github.com/JamesNK/Newtonsoft.Json.git"
$commitToAnalyze=600
$numberOfCommitsToAnalyze=200

function CloneGitRepo {
    param([string] $gitURI, [string] $gitSrcDir)
    $projectCloned = Test-Path $gitSrcDir 
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
    cd $workingDir
} 

function CleanGitDirectory {
    $items= Get-ChildItem -Path  $tiaGitSolutionDirectory -Recurse  |
    Select -ExpandProperty FullName |
    Where {$_ -notlike '*TestAdaptors*'} |
    sort length -Descending |
    Remove-Item -Force
}

function CopyGitHubSrcToVSTSGitRepo {
    Copy-Item "$gitHubSolutionDirectory\*" $tiaGitSolutionDirectory -Recurse
}

CloneGitRepo -gitURI $gitHubSrcURI -gitSrcDir $gitHubSolutionDirectory 

# $numberOfCommitsLeft=$numberOfCommitsToAnalyze
# # while ($numberOfCommitsLeft -gt 0) {
#     #Checkout git commit i commits ago
#     $currentCommit=$commitToAnalyze-($numberOfCommitsToAnalyze - $numberOfCommitsLeft)
#     ReverGitRepoXNumberOfCommintsBack -gitRepoPath $gitHubSolutionDirectory -numberOfCommitsBack $currentCommit

    #Clean the VSTS git directory to copy into
    # CleanGitDirectory

    # #Copy the Source GitHub Repo to VSTS Git Repo
    # CopyGitHubSrcToVSTSGitRepo

    # #Push the new changeset to VSTS
    # PushVSTSGitChanges -m "$currentCommit commits back from current GitHub head"

    # $numberOfCommitsLeft -= 1
    # Start-Sleep -s 30
# }