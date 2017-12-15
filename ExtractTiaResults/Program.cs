using System;
using System.Net.Http;
using System.Runtime.Serialization.Json;
using System.Threading.Tasks;
using System.Collections.Generic;
using System.Linq;
using ExtractTiaResults.Services;
using ExtractTiaResults.Models;
using ExtractTiaResults.models;
using CsvHelper;
using System.IO;

namespace ExtractTiaResults
{
    public class Program
    {
        static void Main(string[] args)
        {
            // ///Newtonsoft parameters
            // var newtonsoftResultApiConfig = new ExtractTiaResultsApiConfig() {
            //     gitHubRepoLocalSourcePath = @"D:\UIUC-GIT\TestProjectsGitHubSourceTIA\Newtonsoft.Json",
            //     vstsRepoLocalSourcePathRepo = @"D:\UIUC-GIT\TestProjectSourceVSTS\NewtonsoftJson",
            //     vstsTiaBuildId = 12,
            //     vstsRetestAllBuildId = 14,
            //     BuildsAfter = new DateTime(2017,12,11,2,20,0),
            //     VstsRepoName = "NewtonsoftJson"
            // };
            // var newtonsofEkstaziSharpResultsDir = @"D:\UIUC-GIT\Results\Ekstazi#\Newtonsoft.Json";

            //Nancy parameters
            var nancyResultApiConfig = new ExtractTiaResultsApiConfig() {
                gitHubRepoLocalSourcePath = @"D:\UIUC-GIT\TestProjectsGitHubSourceTIA\Nancy",
                vstsRepoLocalSourcePathRepo = @"D:\UIUC-GIT\TestProjectSourceVSTS\NancyFx",
                vstsTiaBuildId = 18,
                vstsRetestAllBuildId = 17,
                BuildsAfter = new DateTime(2017,12,15,0,0,0),
                VstsRepoName = "NancyFx"
            };
            var nancyEkstaziSharpResultsDir = @"D:\UIUC-GIT\Results\Ekstazi#\Nancy";

            // //FluentValidation parameters
            // var fluentValidationResultApiConfig = new ExtractTiaResultsApiConfig() {
            //     gitHubRepoLocalSourcePath = @"D:\UIUC-GIT\TestProjectsGitHubSourceTIA\FluentValidation",
            //     vstsRepoLocalSourcePathRepo = @"D:\UIUC-GIT\TestProjectSourceVSTS\FluentValidation",
            //     vstsTiaBuildId = 2,
            //     vstsRetestAllBuildId = 3,
            //     BuildsAfter = new DateTime(2017,12,11, 2,40,0),
            //     VstsRepoName = "FluentValidation"
            // };
            // var fluentValidationEkstaziSharpResultsDir = @"D:\UIUC-GIT\Results\Ekstazi#\FluentValidation";

            // //OptiKey parameters
            // var optiKeyResultApiConfig = new ExtractTiaResultsApiConfig() {
            //     gitHubRepoLocalSourcePath = @"D:\UIUC-GIT\TestProjectsGitHubSourceTIA\OptiKey",
            //     vstsRepoLocalSourcePathRepo = @"D:\UIUC-GIT\TestProjectSourceVSTS\OptiKey",
            //     vstsTiaBuildId = 6,
            //     vstsRetestAllBuildId = 7,
            //     BuildsAfter = new DateTime(2017,12,14,0,0,0),
            //     VstsRepoName = "OptiKey"
            // };
            // var optiKeyEkstaziSharpResultsDir = @"D:\UIUC-GIT\Results\Ekstazi#\OptiKey";

            // //Accord.Net parameters
            // var accordResultApiConfig = new ExtractTiaResultsApiConfig() {
            //     gitHubRepoLocalSourcePath = @"D:\UIUC-GIT\TestProjectsGitHubSourceTIA\framework",
            //     vstsRepoLocalSourcePathRepo = @"D:\UIUC-GIT\TestProjectSourceVSTS\Accord.Net",
            //     vstsTiaBuildId = 15,
            //     vstsRetestAllBuildId = 16,
            //     BuildsAfter = new DateTime(2017,12,7,0,0,0),
            //     VstsRepoName = "Accord.Net"
            // };
            // var accordEkstaziSharpResultsDir = @"D:\UIUC-GIT\Results\Ekstazi#\framework_bad";


            //Grab the results from Visual Studio Team Services
            var vstsResultsApi = new ExtractTiaResultsApi(nancyResultApiConfig);
            var tiaResults = vstsResultsApi.ExtractVstsTiaTestResults().OrderBy(x => x.MetaInfo);
            var retestAllResults = vstsResultsApi.ExtractVstsRetestAllTestResults().OrderBy(x => x.MetaInfo);

            //Grab the results from the local stored Ekstazi# result files
            var ekstaziSharpApi = new ExtractEkstaziSharpResultsApi(nancyEkstaziSharpResultsDir);
            var ekstaziSharpResults = ekstaziSharpApi.ExtractEkstaziResults().OrderBy(x => x.MetaInfo); 

            //Combine the results together
            var comparisonResults = new List<ComparisonResultsModel>();
            foreach(var result in tiaResults)
            {
                var retestAllResult = retestAllResults.FirstOrDefault(x => x.GitHubHash == result.GitHubHash);
                var ekstaziSharpResult = ekstaziSharpResults.FirstOrDefault(x => x.GitHubHash == result.GitHubHash);

                if(retestAllResult != null && ekstaziSharpResult != null)
                {
                    comparisonResults.Add(new ComparisonResultsModel(result, retestAllResult, ekstaziSharpResult, result.GitHubHash));
                }
            }

            //Print the results to a csv file
            using(var sw = new StreamWriter("nancyResults.csv"))
            {
                var csv = new CsvWriter(sw);
                csv.WriteRecords(comparisonResults);
            }
        }
    }
}
