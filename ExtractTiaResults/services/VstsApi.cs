using System;
using System.Net.Http;
using System.Runtime.Serialization.Json;
using System.Threading.Tasks;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using ExtractTiaResults.Models;

namespace ExtractTiaResults.Services
{
    public class VstsApi 
    {
        public List<Build> GetBuildsWithTestRuns(int buildDefId, string repoName, DateTime buildRanAfter = new DateTime()) {
            var builds = this.GetBuilds(buildDefId, repoName, buildRanAfter); 
            foreach(var build in builds)
            {
                var testRun = this.GetTestRun(build, repoName);
                build.testRun = testRun; 
            }
            return builds;
        }
        
        public List<Build> GetBuilds(int buildDefId, string repoName, DateTime buildRanAfter = new DateTime()) {
            var getBuilds = GetBuildsFromVSTS(buildDefId, repoName, buildRanAfter);
            getBuilds.Wait();
            return getBuilds.Result;
        }

        private async Task<List<Build>> GetBuildsFromVSTS(int buildDefId, string repoName, DateTime buildRanAfter)
        {
            var request = string.Format("https://fa17-cs527-48.visualstudio.com/{0}/_apis/build/builds?api-version=2.0&statusFilter=completed&definitions={1}&minFinishTime={2}-{3}-{4}T{5}:{6}:{7}", 
                                        repoName,
                                        buildDefId, 
                                        buildRanAfter.Year.ToString(),
                                        buildRanAfter.Month.ToString(),
                                        buildRanAfter.Day.ToString(),
                                        buildRanAfter.ToString("hh"),
                                        buildRanAfter.ToString("mm"),
                                        buildRanAfter.ToString("ss"));
            var client = new HttpClient();
            client.DefaultRequestHeaders.Add("Authorization", "Basic OmVza3ozc2tlenNieTJrYWd1a3FhaWZ2bnF0enFoZXpxNWtzcm83NmVhNG42NHBwMnBjeXE=");
            var serializer = new DataContractJsonSerializer(typeof(TiaBuildResponse));
            var reqTask = client.GetStreamAsync(request);
            var builds = serializer.ReadObject(await reqTask) as TiaBuildResponse;
            return builds.value; 
        }

        public TestRun GetTestRun(Build build, string repoName)
        {
            var getTestRun = GetTestRunFromVSTS(build.uri, repoName);
            getTestRun.Wait();
            return getTestRun.Result;
        }

        private async Task<TestRun> GetTestRunFromVSTS(string buildUri, string repoName)
        {
            var request = string.Format("https://fa17-cs527-48.visualstudio.com/{0}/_apis/test/runs?includeRunDetails=true&api-version=1.0&buildUri={1}", repoName, buildUri);
            var client = new HttpClient();
            client.DefaultRequestHeaders.Add("Authorization", "Basic OmVza3ozc2tlenNieTJrYWd1a3FhaWZ2bnF0enFoZXpxNWtzcm83NmVhNG42NHBwMnBjeXE=");
            var serializer = new DataContractJsonSerializer(typeof(TiaTestRunResponse));
            var reqTask = client.GetStreamAsync(request);
            var testRuns = serializer.ReadObject(await reqTask) as TiaTestRunResponse;
            return testRuns.value.SingleOrDefault();
        }
    }
}
