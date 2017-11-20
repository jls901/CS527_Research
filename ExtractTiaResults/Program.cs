using System;
using System.Net.Http;
using System.Runtime.Serialization.Json;
using System.Threading.Tasks;
using System.Collections.Generic;
using System.Linq;
using ExtractTiaResults.Services;
using ExtractTiaResults.Models;

namespace ExtractTiaResults
{
    class Program
    {
        static void Main(string[] args)
        {
            var gitApi = new GitApi(@"D:\UIUC-GIT\TestProjectSourceVSTS\OptiKey");
            var sha1s = gitApi.GetCommitSha1s(200, 200);

            var vstsApi = new VstsApi();
            var tiaBuilds = vstsApi.GetBuildsWithTestRuns(6);
            var regBuilds = vstsApi.GetBuildsWithTestRuns(7);

            var buildsToAnalyze = new List<Build>(); 
            var colHeaders = string.Format("{0} \t {1} \t {2} \t {3} \t {4} \t {5} \t {6} \t {7} \t {8}", "Checkin", 
                                                "TIA Runtime", "TIA Total Tests", "TIA Passed Tests", "TIA Unanalyzed Tests", 
                                                "Reg Runtime", "Reg Total Tests", "Reg Passed Tests", "Reg Unanalyzed Tests");
            Console.WriteLine(colHeaders.ToString());

            foreach(var sha1 in sha1s)
            {
                var tiaBuild = tiaBuilds.FirstOrDefault(x => x.sourceVersion == sha1.Value);
                var regBuild = regBuilds.FirstOrDefault(x => x.sourceVersion == sha1.Value);

                if(tiaBuild.testRun != null && regBuild.testRun != null)
                {
                    var formattedOutput = string.Format("{0} \t {1} \t {2} \t {3} \t {4} \t {5} \t {6} \t {7} \t {8}", sha1.Key, 
                                                            tiaBuild.testRun.runTime.ToString(), tiaBuild.testRun.totalTests, tiaBuild.testRun.passedTests, tiaBuild.testRun.unanalyzedTests, 
                                                            regBuild.testRun.runTime.ToString(), regBuild.testRun.totalTests, regBuild.testRun.passedTests, regBuild.testRun.unanalyzedTests);
                    Console.WriteLine(formattedOutput);
                }
            }
        }
    }
}
