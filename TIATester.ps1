$tiaGitDirectory="/Users/jsmith/GitSrcUIUC/TestProjectSourceVSTS"
$gitHubDirectory="/Users/jsmith/GitSrcUIUC/TestProjects"
$gitHubSrcURI="https://github.com/OptiKey/OptiKey.git"
$commitToAnalyze=200

function CloneGitRepo {
    param([string] $gitURI, [string] $gitSrcDir)
    $projectCloned = Test-Path $solutionUnderTestPath 
    if (-Not $projectCloned) {
        echo "Cloning the project under test git repo"
        git clone $gitURI "$gitSrcDir\$solutionName"
    }
}

function ResetGitRepo {
    git fetch origin
    git reset --hard origin/master
    git clean -xdff -e **/*/storage.ide
}

function CommitVSTSGitChanges {
    param([string] $msg)
    git add -u
    git commit -m $msg
}

function PushVSTSGitChanges {
    param([string] $msg)
    $workingDir = pwd
    cd $tiaGitDirectory
    CommitVSTSGitChanges -msg $msg
    git push
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

function CopyGitHubRepoToTFSGitRepo{
    param([string] $gitHubLocalPath, [string] $tfsRepoLocalPath)
}

function CleanGitDirectory {
    $items= Get-ChildItem -Path  $tiaGitDirectory -Recurse  |
    Select -ExpandProperty FullName |
    Where {$_ -notlike '*TestAdaptors*'} |
    sort length -Descending |
    Remove-Item -Force
}

function CopyGitHubSrcToVSTSGitRepo {
    Copy-Item "$gitHubDirectory\*" $tiaGitDirectory -Recurse
}

CloneGitRepo -gitURI $gitHubSrcURI $gitHubDirectory

while ($commitToAnalyze -gt 0) {
    #Checkout git commit i commits ago
    ReverGitRepoXNumberOfCommintsBack -gitRepoPath $solutionUnderTestPath -numberOfCommitsBack $commitToAnalyze

    #Clean the VSTS git directory to copy into
    CleanGitDirectory

    $commitToAnalyze -= 1
}