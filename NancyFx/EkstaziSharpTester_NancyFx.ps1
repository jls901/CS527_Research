$output_file="./README.log"

# -General
$checkoutDir="D:\UIUC-GIT\TestProjects"
$testingFramework="XUnit1"
$resultsDir="D:\UIUC-GIT\Results\Ekstazi#"
$commitToAnalyze=340    
$numberOfCommitsToAnalyze=60

# -EkstaziPaths
$ekstaziSharpProjectPath="D:\UIUC-GIT\ekstaziSharp"
$ekstaziSharpSolutionFile="$ekstaziSharpProjectPath\tool\ekstaziSharp.sln"
$ekstaziSharpProjectFile="$ekstaziSharpProjectPath\tool\EkstaziTesterSharp.Tester\EkstaziSharp.Tester.csproj"
$ekstaziSharpExecutable="$ekstaziSharpProjectPath\build\EkstaziSharp.Tester\ekstaziSharpTester.exe"

# -SolutionUnderTestPaths
$solutionName="Nancy"
$solutionUnderTestPath="$checkoutDir\$solutionName"
$solutionUnderTestSolutionFilePath="src\Nancy.sln"
$programModulesPath="src\Nancy.Authentication.Basic.Tests\bin\Debug\Nancy.dll,"`
                     + "src\Nancy.Authentication.Basic.Tests\bin\Debug\Nancy.Authentication.Basic.dll,"`
                     + "src\Nancy.Authentication.Forms.Tests\bin\Debug\Nancy.Authentication.Forms.dll,"`
                     + "src\Nancy.Embedded.Tests\bin\Debug\Nancy.Embedded.dll,"`
                     + "src\Nancy.Encryption.MachineKey.Tests\bin\Debug\Nancy.Encryption.MachineKey.dll,"`
                     + "src\Nancy.Hosting.Aspnet.Tests\bin\Debug\Nancy.Hosting.Aspnet.dll,"`
                     + "src\Nancy.Hosting.Self.Tests\bin\Debug\Nancy.Hosting.Self.dll,"`
                     + "src\Nancy.Owin.Tests\bin\Debug\Nancy.Owin.dll,"`
                     + "src\Nancy.Testing.Tests\bin\Debug\Nancy.Testing.dll,"`
                     + "src\Nancy.Validation.FluentValidation.Tests\bin\Debug\Nancy.Validation.FluentValidation.dll,"`
                     + "src\Nancy.Validation.DataAnnotatioins.Tests\bin\Debug\Nancy.Validation.DataAnnotations.dll,"`
                     + "src\Nancy.ViewEngines.DotLiquid.Tests\bin\Debug\Nancy.ViewEngines.DotLiquid.dll,"`
                     + "src\Nancy.ViewEngines.Markdown.Tests\bin\Debug\Nancy.ViewEngines.Markdown.dll,"`
                     + "src\Nancy.ViewEngines.Razor.Tests\bin\Debug\Nancy.ViewEngines.Razor.dll,"`
                     + "src\Nancy.ViewEngines.Spark.Tests\bin\Debug\Nancy.ViewEngines.Spark.dll"
                     #+ "src\Nancy.Metadata.Modules.Tests\bin\Debug\Nancy.Metadata.Modules.dll,"`

$testModulesPath="src\Nancy.Authentication.Basic.Tests\bin\Debug\Nancy.Authentication.Basic.Tests.dll,"`
                  + "src\Nancy.Authentication.Forms.Tests\bin\Debug\Nancy.Authentication.Forms.Tests.dll,"`
                  + "src\Nancy.Embedded.Tests\bin\Debug\Nancy.Embedded.Tests.dll,"`
                  + "src\Nancy.Encryption.MachineKey.Tests\bin\Debug\Nancy.Encryption.MachineKey.Tests.dll,"`
                  + "src\Nancy.Hosting.Aspnet.Tests\bin\Debug\Nancy.Hosting.Aspnet.Tests.dll,"`
                  + "src\Nancy.Hosting.Self.Tests\bin\Debug\Nancy.Hosting.Self.Tests.dll,"`
                  + "src\Nancy.Owin.Tests\bin\Debug\Nancy.Owin.Tests.dll,"`
                  + "src\Nancy.Testing.Tests\bin\Debug\Nancy.Testing.Tests.dll,"`
                  + "src\Nancy.Tests\bin\Debug\Nancy.Tests.dll,"`
                  + "src\Nancy.Tests.Functional\bin\Debug\Nancy.Tests.Functional.dll,"`
                  + "src\Nancy.Validation.FluentValidation.Tests\bin\Debug\Nancy.Validation.FluentValidation.Tests.dll,"`
                  + "src\Nancy.Validation.DataAnnotatioins.Tests\bin\Debug\Nancy.Validation.DataAnnotations.Tests.dll,"`
                  + "src\Nancy.ViewEngines.DotLiquid.Tests\bin\Debug\Nancy.ViewEngines.DotLiquid.Tests.dll,"`
                  + "src\Nancy.ViewEngines.Markdown.Tests\bin\Debug\Nancy.ViewEngines.Markdown.Tests.dll,"`
                  + "src\Nancy.ViewEngines.Razor.Tests\bin\Debug\Nancy.ViewEngines.Razor.Tests.dll,"`
                  + "src\Nancy.ViewEngines.Spark.Tests\bin\Debug\Nancy.ViewEngines.Spark.Tests.dll"
                  #+ "src\Nancy.Metadata.Modules.Tests\bin\Debug\Nancy.Metadata.Modules.Tests.dll,"`
                  

$gitHubSrcURI="https://github.com/NancyFx/Nancy.git"

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