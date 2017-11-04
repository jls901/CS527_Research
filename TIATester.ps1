$tiaGitDirectory="D:\UIUC-GIT\TestProjectSourceVSTS\OptiKey\Test"
$gitHubDirectory="D:\UIUC-GIT\TestProjects\OptiKey"

function CloneGitRepo {
    param([string] $gitURI, [string] $gitSrcDir)
    $projectCloned = Test-Path $solutionUnderTestPath 
    if (-Not $projectCloned) {
        echo "Cloning the project under test git repo"
        git clone $solutionUnderTestGitHTTTPS "$gitSrcDir\$solutionName"
    }
}

function ResetGitRepo {
    git fetch origin
    git reset --hard origin/master
    git clean -xdff -e **/*/storage.ide
}

function CommitVSTSGitChanges {
    
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





