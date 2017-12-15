$output_file="./README.log"

# -General
$checkoutDir="D:\UIUC-GIT\TestProjects"
$testingFramework="NUnit2"
$resultsDir="D:\UIUC-GIT\Results\Ekstazi#"
$commitToAnalyze=760
$numberOfCommitsToAnalyze=60

# -EkstaziPaths
$ekstaziSharpProjectPath="D:\UIUC-GIT\ekstaziSharp"
$ekstaziSharpSolutionFile="$ekstaziSharpProjectPath\tool\ekstaziSharp.sln"
$ekstaziSharpProjectFile="$ekstaziSharpProjectPath\tool\EkstaziTesterSharp.Tester\EkstaziSharp.Tester.csproj"
$ekstaziSharpExecutable="$ekstaziSharpProjectPath\build\EkstaziSharp.Tester\ekstaziSharpTester.exe"

# -SolutionUnderTestPaths
$solutionName="FluentValidation"
$solutionUnderTestPath="$checkoutDir\$solutionName"
$solutionUnderTestSolutionFilePath="\FluentValidation.sln"
# $programModulesPath="src\FluentValidation.Tests\bin\Debug\FluentValidation.dll,src\FluentValidation.Tests.Mvc3\bin\Debug\FluentValidation.Mvc.dll"
# $testModulesPath="src\FluentValidation.Tests\bin\Debug\FluentValidation.Tests.dll,src\FluentValidation.Tests.Mvc3\bin\Debug\FluentValidation.Tests.Mvc3.dll"
$programModulesPath="src\FluentValidation.Tests\bin\Debug\FluentValidation.dll,src\FluentValidation.Tests\bin\Debug\FluentValidation.Mvc.dll"
$testModulesPath="src\FluentValidation.Tests\bin\Debug\FluentValidation.Tests.dll"
$gitHubSrcURI="https://github.com/JeremySkinner/FluentValidation.git"

function Build-DotNetProject {
    param([string] $projectPath, [string] $output_file)
    msbuild $projectPath /verbosity:quiet /t:Clean,Build >> $output_file
}

function NugetRestore-DotNetProject{
    param([string] $projectSolution, [string] $output_file)
    D:/UIUC-GIT/ekstaziSharp/tool/tests/nuget.exe restore $projectSolution >> $output_file
}

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

function RunEkstaziSharp {
    param([string] $projectpath, [string] $solutionPath, [string] $programModules, [string] $testModules, 
          [string] $testingFramework, [string] $outputDir, [string] $inputDir, [string] $ekstaziExecutable)
     &$ekstaziExecutable `
          --testSource LocalProject `
	      --projectPath $projectPath `
	      --solutionPath $solutionPath `
	      --programModules $programModules `
	      --testModules $testModules `
	      --testingFramework $testingFramework `
	      --outputDirectory $outputDir `
          --inputDirectory $inputDir `
	      --debug `
}

function GetCurrentGitHubCommitHash {
    param([string] $gitRepoPath)
    $workingDir = pwd
    cd $gitRepoPath
    $gitHash = git rev-parse HEAD 
    cd $workingDir
    return $gitHash
}

function SetupEkstaziSharp {
    # -Fetching EkstaziSharp dependencies
    echo "Fetching EkstaziSharp dependencies"
    echo $ekstaziSharpSolutionFile
    NugetRestore-DotNetProject -projectSolution $ekstaziSharpSolutionFile -output_file $output_file

    # -Building EkstaziSharp project
    echo "Building EkstaziSharp project"
    Build-DotNetProject -projectPath $ekstaziSharpProjectFile -output_file $output_file
}

#Restore nuget packages and build ekstazi# project
SetupEkstaziSharp

# -Setting up project under test
CloneGitRepo -gitURI $gitHubSrcURI -gitSrcDir $checkoutDir

$numberOfCommitsLeft=$numberOfCommitsToAnalyze
while ($numberOfCommitsLeft -gt 0) {
    #Checkout git commit i commits ago
    $currentCommit=$commitToAnalyze-($numberOfCommitsToAnalyze - $numberOfCommitsLeft)
    ReverGitRepoXNumberOfCommintsBack -gitRepoPath $solutionUnderTestPath -numberOfCommitsBack $currentCommit 

    # -Building a test project
    echo "Restoring nuget packages and building the test project"
    NugetRestore-DotNetProject -projectSolution "$solutionUnderTestPath\$solutionUnderTestSolutionFilePath" -output_file $output_file 
    echo "$solutionUnderTestPath\$solutionUnderTestSolutionFilePath"
    Build-DotNetProject -projectPath "$solutionUnderTestPath\$solutionUnderTestSolutionFilePath" -output_file $output_file

    # -Running test with EkstaziSharp
    echo "Running tests using EkstaziSharp"
    $gitCommitHash = GetCurrentGitHubCommitHash -gitRepoPath $solutionUnderTestPath 
    $fullOutputDir="$resultsDir\$solutionName\${currentCommit}_${gitCommitHash}_Results"
    $fullInputDir="$resultsDir\$solutionName\ekstaziInfo\"
    RunEkstaziSharp -projectPath $solutionUnderTestPath -solutionPath $solutionUnderTestSolutionFilePath -programModules $programModulesPath `
                    -testModules $testModulesPath -testingFramework $testingFramework -outputDir $fullInputDir -inputDir $fullInputDir `
                    -ekstaziExecutable $ekstaziSharpExecutable 

    New-Item $fullOutputDir -Type Directory
    Copy-Item $resultsDir\$solutionName\ekstaziInfo\.ekstaziSharp\ekstaziInformation\executionLogs\* $fullOutputDir -Recurse -Force
    Copy-Item $resultsDir\$solutionName\ekstaziInfo\.ekstaziSharp\ekstaziInformation\affected.json $fullOutputDir -Recurse -Force
    Copy-Item $resultsDir\$solutionName\ekstaziInfo\.ekstaziSharp\ekstaziInformation\checksums.txt $fullOutputDir -Recurse -Force
    $numberOfCommitsLeft -= 1
}


