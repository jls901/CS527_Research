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
        public List<Build> GetBuilds(int buildDefId) {
            var getBuilds = GetBuildsFromVSTS(buildDefId);
            getBuilds.Wait();
            return getBuilds.Result;
        }
    
        public List<Build> GetBuildsWithTestRuns(int buildDefId) {
            var builds = this.GetBuilds(buildDefId); 
            foreach(var build in builds)
            {
                var testRun = this.GetTestRun(build);
                build.testRun = testRun; 
            }
            return builds;
        }

        private async Task<List<Build>> GetBuildsFromVSTS(int buildDefId)
        {
            var request = string.Format("https://fa17-cs527-48.visualstudio.com/OptiKey/_apis/build/builds?api-version=2.0&statusFilter=completed&definitions={0}&minFinishTime=2017-11-6T00:00:00&sourceVersion=c54299272ee41b2197ddea74395e709dba59bbe7", buildDefId);
            var client = new HttpClient();
            client.DefaultRequestHeaders.Add("Authorization", "Basic OmVza3ozc2tlenNieTJrYWd1a3FhaWZ2bnF0enFoZXpxNWtzcm83NmVhNG42NHBwMnBjeXE=");
            var serializer = new DataContractJsonSerializer(typeof(TiaBuildResponse));
            var reqTask = client.GetStreamAsync(request);
            var builds = serializer.ReadObject(await reqTask) as TiaBuildResponse;
            return builds.value; 
        }

        public TestRun GetTestRun(Build build)
        {
            var getTestRun = GetTestRunFromVSTS(build.uri);
            getTestRun.Wait();
            return getTestRun.Result;
        }

        private async Task<TestRun> GetTestRunFromVSTS(string buildUri)
        {
            var request = string.Format("https://fa17-cs527-48.visualstudio.com/OptiKey/_apis/test/runs?includeRunDetails=true&api-version=1.0&buildUri={0}", buildUri);
            var client = new HttpClient();
            client.DefaultRequestHeaders.Add("Authorization", "Basic OmVza3ozc2tlenNieTJrYWd1a3FhaWZ2bnF0enFoZXpxNWtzcm83NmVhNG42NHBwMnBjeXE=");
            var serializer = new DataContractJsonSerializer(typeof(TiaTestRunResponse));
            var reqTask = client.GetStreamAsync(request);
            var testRuns = serializer.ReadObject(await reqTask) as TiaTestRunResponse;
            return testRuns.value.SingleOrDefault();
        }
    }
}
