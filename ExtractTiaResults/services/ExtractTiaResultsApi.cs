using System;
using System.Net.Http;
using System.Runtime.Serialization.Json;
using System.Threading.Tasks;
using System.Collections.Generic;
using System.Linq;
using ExtractTiaResults.Services;
using ExtractTiaResults.Models;

namespace ExtractTiaResults.Services
{
    public class ExtractTiaResultsApi
    {
        private ExtractTiaResultsApiConfig tiaExtractConfig;
        private GitApi gitApi;
        private VstsApi vstsApi;
        private BuildService buildService;

        public ExtractTiaResultsApi(ExtractTiaResultsApiConfig config)
        {
            this.tiaExtractConfig = config;
            this.gitApi = new GitApi(this.tiaExtractConfig.vstsRepoLocalSourcePathRepo, this.tiaExtractConfig.gitHubRepoLocalSourcePath);
            this.buildService = new BuildService(this.gitApi);
            this.vstsApi = new VstsApi();
        }

        public IEnumerable<TestResults> ExtractVstsTiaTestResults() 
        {
            var resultsTia = new List<TestResults>();

            //Get the most recent builds for a build definition
            var tiaBuilds = this.vstsApi.GetBuildsWithTestRuns(this.tiaExtractConfig.vstsTiaBuildId, this.tiaExtractConfig.VstsRepoName, this.tiaExtractConfig.BuildsAfter);

            //Get the GitHub Sha1s
            buildService.PopulateGitHubSha1sForBuilds(tiaBuilds);

            foreach(var tiaBuild in tiaBuilds)
            {
                if(tiaBuild.testRun != null)
                {
                    resultsTia.Add(this.CreateTestResultsFromVstsBuild(tiaBuild));
                }
            }
            return resultsTia;
        }
        
        public IEnumerable<TestResults> ExtractVstsRetestAllTestResults() 
        {
            var resultsRetestAll = new List<TestResults>();

            //Get the most recent builds for a build definition
            var regBuilds = this.vstsApi.GetBuildsWithTestRuns(this.tiaExtractConfig.vstsRetestAllBuildId, this.tiaExtractConfig.VstsRepoName, this.tiaExtractConfig.BuildsAfter);

            //Get the GitHub Sha1s
            buildService.PopulateGitHubSha1sForBuilds(regBuilds);

            foreach(var regBuild in regBuilds)
            {
                if(regBuild.testRun != null)
                {
                    resultsRetestAll.Add(this.CreateTestResultsFromVstsBuild(regBuild));
                }
            }
            return resultsRetestAll;
        }

        public TestResults CreateTestResultsFromVstsBuild(Build build)
        {
            return new TestResults() {
                GitHubHash = build.GitHubSha1,
                TotalTests = build.testRun.totalTests,
                NumberOfUnAnalyzedTests = build.testRun.unanalyzedTests,
                NumberofTestsPassed = build.testRun.passedTests,
                Runtime = build.testRun.runTime,
                MetaInfo = build.VstsCommitMessage
            };
        }
    }
}