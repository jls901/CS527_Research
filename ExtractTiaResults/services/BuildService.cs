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
    public class BuildService 
    {
        private GitApi gitApi;
        public BuildService(GitApi gitApi)
        {
            this.gitApi = gitApi;
        }

        public void PopulateGitHubSha1sForBuilds(IEnumerable<Build> builds)
        {
            foreach(var build in builds)
            {
                var gitCommitMessage = gitApi.GetVstsCommitMessageForTriggeredBuild(build);
                build.VstsCommitMessage = gitCommitMessage;
                build.GitHubSha1 = this.ExtractGitHubHashFromCommitMessage(gitCommitMessage);
            }
        }

        private string ExtractGitHubHashFromCommitMessage(string commitMessage)
        {
            var hashStartIndex = commitMessage.IndexOf(":") + 1;
            return commitMessage.Substring(hashStartIndex);
        }
    }
}