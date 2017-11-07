$output_file="./README.log"

# -General
$checkoutDir="D:\UIUC-GIT\TestProjects"
$testingFramework="NUnit2"
$resultsDir="D:\UIUC-GIT\Results\Ekstazi#"
$commitToAnalyze=350
$numberOfCommitsToAnalyze=200

# -EkstaziPaths
$ekstaziSharpProjectPath="D:\UIUC-GIT\ekstaziSharp"
$ekstaziSharpSolutionFile="$ekstaziSharpProjectPath\tool\ekstaziSharp.sln"
$ekstaziSharpProjectFile="$ekstaziSharpProjectPath\tool\Tester\EkstaziSharp.Tester.csproj"
$ekstaziSharpExecutable="$ekstaziSharpProjectPath\tool\Tester\bin\Debug\ekstaziSharpTester.exe"

# -SolutionUnderTestPaths
$solutionName="OptiKey"
$solutionUnderTestPath="$checkoutDir\$solutionName"
$solutionUnderTestSolutionFilePath="$solutionName.sln"
$projectUnderTestCsprojFilePath="src\JuliusSweetland.OptiKey\JuliusSweetland.OptiKey.csproj"
$programModulesPath="src\JuliusSweetland.OptiKey.UnitTests\bin\Debug\OptiKey.exe"
$testModulesPath="src\JuliusSweetland.OptiKey.UnitTests\bin\Debug\JuliusSweetland.OptiKey.UnitTests.dll"


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
        git clone $solutionUnderTestGitHTTTPS "$gitSrcDir\$solutionName"
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
    cd $workingDir
} 

function RunEkstaziSharp {
    param([string] $projectpath, [string] $solutionPath, [string] $programModules, [string] $testModules, 
          [string] $testingFramework, [string] $outputDir, [string] $inputDir, [string] $projectFilePath,
          [string] $ekstaziExecutable)
     &$ekstaziExecutable `
          --testSource LocalProject `
	      --projectPath $projectPath `
          --projectFilePath $projectFilePath `
	      --solutionPath $solutionPath `
	      --programModules $programModules `
	      --testModules $testModules `
	      --testingFramework $testingFramework `
	      --outputDirectory $outputDir `
	      --inputDirectory $inputDir `
	      --debug `
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
CloneGitRepo -gitURI $solutionUnderTestGitHTTTPS -gitSrcDir $checkoutDir

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
    $fullOutputDir="$resultsDir\$solutionName\${currentCommit}_Results"
    $fullInputDir="$resultsDir\$solutionName\ekstaziInfo\"
    echo $fullInputDir
    RunEkstaziSharp -projectPath $solutionUnderTestPath -solutionPath $solutionUnderTestSolutionFilePath -programModules $programModulesPath `
                    -testModules $testModulesPath -testingFramework $testingFramework -outputDir $fullInputDir -inputDir $fullInputDir `
                    -projectFilePath $projectUnderTestCsprojFilePath -ekstaziExecutable $ekstaziSharpExecutable 

    New-Item $fullOutputDir -Type Directory
    Copy-Item $resultsDir\$solutionName\ekstaziInfo\.ekstaziSharp\ekstaziInformation\executionLogs\* $fullOutputDir -Recurse -Force
    Copy-Item $resultsDir\$solutionName\ekstaziInfo\.ekstaziSharp\ekstaziInformation\affected.json $fullOutputDir -Recurse -Force
    Copy-Item $resultsDir\$solutionName\ekstaziInfo\.ekstaziSharp\ekstaziInformation\checksums.txt $fullOutputDir -Recurse -Force
    $numberOfCommitsLeft -= 1
}


