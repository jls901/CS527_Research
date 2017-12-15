using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text.RegularExpressions;
using ExtractTiaResults.Models;

namespace ExtractTiaResults.Services
{
    public class ExtractEkstaziSharpResultsApi
    {
        private string resultsDirectory;

        public ExtractEkstaziSharpResultsApi(string resultsDirectory)
        {
            this.resultsDirectory = resultsDirectory;
        }

        public IEnumerable<TestResults> ExtractEkstaziResults()
        {
            var ekstaziResulstFolders = Directory.GetDirectories(this.resultsDirectory).ToList().Where(x => !x.Contains("ekstazi")).ToList();
            var testResults = new List<TestResults>(); 

            foreach(var resultDir in ekstaziResulstFolders.OrderByDescending(x => x))
            {
                var resultFile = @resultDir + @"\test_results.txt";
                if (File.Exists(resultFile))
                {
                    //Basic test stats
                    var runtime = string.Empty;
                    var totalTests = string.Empty;
                    var passedTests = string.Empty;
                    var failedTests = string.Empty;
                    var unanalyzedTests = string.Empty;

                    var fileLines = File.ReadLines(resultFile);
                    foreach(var line in fileLines)
                    {
                        if (Regex.Matches(line, @"ExecutionTime").Any())
                        {
                            var runtimeMatches = Regex.Matches(line, @"\d+\.\d+");
                            runtime = runtimeMatches.Any() ? runtimeMatches.FirstOrDefault().ToString() : string.Empty;
                        }
                        else if (Regex.Matches(line, @"TotalNumberOfTestMethods").Any())
                        {
                            var totalTestMatches = Regex.Matches(line, @"\d+");
                            totalTests = totalTestMatches.Any() ? totalTestMatches.FirstOrDefault().ToString() : string.Empty;
                        }
                        else if (Regex.Matches(line, @"PassedTestMethodsCount").Any())
                        {
                            var passedTestMatches = Regex.Matches(line, @"\d+");
                            passedTests = passedTestMatches.Any() ? passedTestMatches.FirstOrDefault().ToString() : string.Empty;
                        }
                        else if (Regex.Matches(line, @"FailedTestMethodsCount").Any())
                        {
                            var failedTestMatches = Regex.Matches(line, @"\d+");
                            failedTests = failedTestMatches.Any() ? failedTestMatches.FirstOrDefault().ToString() : string.Empty;
                        }
                    }

                    unanalyzedTests = (Convert.ToInt32(totalTests) - (Convert.ToInt32(passedTests) + Convert.ToInt32(failedTests))).ToString();
                    var folderName = Path.GetFileName(resultDir);
                    testResults.Add(new TestResults() {
                        GitHubHash = this.ExtractGitHubHashFromFolderName(folderName),
                        MetaInfo = folderName,
                        TotalTests = Convert.ToInt32(totalTests),
                        NumberOfTestsFailed = Convert.ToInt32(failedTests),
                        NumberOfUnAnalyzedTests = Convert.ToInt32(unanalyzedTests),
                        NumberofTestsPassed = Convert.ToInt32(passedTests),
                        Runtime = TimeSpan.FromSeconds(Convert.ToDouble(runtime))
                    });
                }
            }
            return testResults;
        }
    
        private string ExtractGitHubHashFromFolderName(string folderName)
        {
            var startIndex = folderName.IndexOf("_") + 1;
            var endIndex = folderName.LastIndexOf("_");
            var length = endIndex - startIndex;
            return folderName.Substring(startIndex, length);
        }

    }
}