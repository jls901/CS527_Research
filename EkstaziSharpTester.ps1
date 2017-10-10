$output_file="README.log"

# -General
$checkoutDir="D:\UIUC-GIT\TestProjects"
$testingFramework="NUnit2"
$resultsDir="$checkoutDir\Results"
$numberOfCommitsToAnalyze=5

# -EkstaziPaths
$ekstaziSharpProjectPath="D:\UIUC-GIT\ekstaziSharp"
$ekstaziSharpSolutionFile="$ekstaziSharpProjectPath\tool\ekstaziSharp.sln"
$ekstaziSharpProjectFile="$ekstaziSharpProjectPath\tool\Tester\EkstaziSharp.Tester.csproj"
$ekstaziSharpExecutable="$ekstaziSharpProjectPath\tool\Tester\bin\Debug\ekstaziSharpTester.exe"

# -SolutionUnderTestPaths
$solutionName="FluentValidation"
$solutionUnderTestPath="$checkoutDir\$solutionName"
$solutionUnderTestProjectFile="$solutionUnderTestPath\src\FluentValidation.Tests\FluentValidation.Tests.csproj"
$solutionUnderTestSolutionFile="$solutionUnderTestPath\$solutionName.sln"
$solutionUnderTestProgramModules="$solutionUnderTestPath\src\FluentValidation.Tests\bin\Debug\net452\FluentValidation.dll"
$solutionUnderTestTestModules="$solutionUnderTestPath\src\FluentValidation.Tests\bin\Debug\net452\FluentValidation.Tests.dll"
$solutionUnderTestGitHTTTPS="https://github.com/JeremySkinner/FluentValidation.git"

function Build-DotNetProject {
    param([string] $projectPath, [string] $output_file)
    msbuild $projectPath /verbosity:quiet >> $output_file
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
    ResetGitRepo --gitRepoPath $gitRepoPath
    git reset --hard HEAD~$numberOfCommitsBack
    git clean -xdff -e **/*/storage.ide
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


for($i=$numberOfCommitsToAnalyze; $i -gt 0; $i-1) {
    #Checkout git commit i commits ago
    ReverGitRepoXNumberOfCommintsBack -gitRepoPath $solutionUnderTestPath -numberOfCommitsBack $i
    # -Building a test project
    echo "Restoring nuget packages and building the test project"
    NugetRestore-DotNetProject -projectSolution $solutionUnderTestSolutionFile -output_file $output_file 
    Build-DotNetProject -projectPath $solutionUnderTestProjectFile -output_file $output_file

    # -Running test with EkstaziSharp
    echo "Running tests using EkstaziSharp"
    RunEkstaziSharp -projectPath $solutionUnderTestPath -solutionPath $solutionUnderTestSolutionFile -programModules $solutionUnderTestProgramModules `
                    -testModules $solutionUnderTestTestModules -testingFramework $testingFramework -outputDir $resultsDir -inputDir $resultsDir `
                    -ekstaziExecutable $ekstaziSharpExecutable `
}


