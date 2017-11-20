using System;
using System.IO;
using System.Linq;
using System.Text.RegularExpressions;

namespace ExtractEkstaziSharpResults
{
    class Program
    {
        static void Main(string[] args)
        {
            var workingDir = @"D:\UIUC-GIT\Results\Ekstazi#\OptiKey"; 
            var restultDirectories = Directory.GetDirectories(workingDir).ToList().Where(x => !x.Contains("ekstazi")).ToList();

            var colHeaders = string.Format("{0} \t {1} \t {2} \t {3} \t {4}", "Checkin", 
                                                "TIA Runtime", "TIA Total Tests", "TIA Passed Tests", "TIA Unanalyzed Tests");
            Console.WriteLine(colHeaders.ToString());

            foreach(var resultDir in restultDirectories.OrderByDescending(x => x))
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

                    var folderName = Path.GetFileName(resultDir);
                    unanalyzedTests = (Convert.ToInt32(totalTests) - (Convert.ToInt32(passedTests) + Convert.ToInt32(failedTests))).ToString();
                    var formattedOutput = string.Format("{0} \t {1} \t {2} \t {3} \t {4}", folderName, 
                                                            runtime, totalTests, passedTests, failedTests);
                    Console.WriteLine(formattedOutput);
                }
            }
        }
    }
}
