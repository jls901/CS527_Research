$output_file="./README.log"

# -General
$checkoutDir="D:\UIUC-GIT\TestProjects"
$testingFramework="NUnit2"
$resultsDir="D:\UIUC-GIT\Results\Ekstazi#"
$commitToAnalyze=200

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


while ($commitToAnalyze -gt 0) {
    #Checkout git commit i commits ago
    ReverGitRepoXNumberOfCommintsBack -gitRepoPath $solutionUnderTestPath -numberOfCommitsBack $commitToAnalyze

    # -Building a test project
    echo "Restoring nuget packages and building the test project"
    NugetRestore-DotNetProject -projectSolution "$solutionUnderTestPath\$solutionUnderTestSolutionFilePath" -output_file $output_file 
    echo "$solutionUnderTestPath\$solutionUnderTestSolutionFilePath"
    Build-DotNetProject -projectPath "$solutionUnderTestPath\$solutionUnderTestSolutionFilePath" -output_file $output_file

    # -Running test with EkstaziSharp
    echo "Running tests using EkstaziSharp"
    $fullOutputDir="$resultsDir\$solutionName\${commitToAnalyze}_Results"
    $previousCommit=$commitToAnalyze+1
    $fullInputDir="$resultsDir\$solutionName\${previousCommit}_Results"
    echo $fullInputDir
    RunEkstaziSharp -projectPath $solutionUnderTestPath -solutionPath $solutionUnderTestSolutionFilePath -programModules $programModulesPath `
                    -testModules $testModulesPath -testingFramework $testingFramework -outputDir $fullOutputDir -inputDir "$fullInputDir" `
                    -projectFilePath $projectUnderTestCsprojFilePath -ekstaziExecutable $ekstaziSharpExecutable 

    $commitToAnalyze -= 1
}


