using System;
using System.Net.Http;
using System.Runtime.Serialization.Json;
using System.Threading.Tasks;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using ExtractTiaResults.Models;
using System.Diagnostics;

namespace ExtractTiaResults.Services
{
    public class GitApi 
    {
        private string vstsgitRepoDirectory = string.Empty;
        private string gitHubGitRepo = string.Empty;

        public GitApi(string vstsGitRepo, string gitHubGitRepo)
        {
            this.vstsgitRepoDirectory = vstsGitRepo;
            this.gitHubGitRepo = gitHubGitRepo;
        }

        public Dictionary<string, string> GetVSTSCommitSha1s(int buildsBack, int numberOfBuilds)
        {
            var commitShas = new Dictionary<string, string>(); 
            var numberOfCommitsLeft = numberOfBuilds; 
            while(numberOfCommitsLeft > 0)
            {
                var currentCommit = buildsBack-(numberOfBuilds - numberOfCommitsLeft);
                var commitSha1 = this.GetCommitSha1XCommitsBack(currentCommit);
                var commitMsg = this.GetCommitMessage(commitSha1);
                commitShas.Add(commitMsg, commitSha1);
                numberOfCommitsLeft--; 
            }
            return commitShas;
        }

        public string GetVstsCommitMessageForTriggeredBuild(Build build) 
        {
            var command = string.Format("show -s --oneline {0}", build.sourceVersion).ToString();
            return RunGitCommand(command, this.vstsgitRepoDirectory);
        }
    
        private string GetCommitMessage(string commitId)
        {
            var command = string.Format("show -s --oneline {0}", commitId).ToString();
            return RunGitCommand(command, this.vstsgitRepoDirectory);
        } 
        
        private string GetCommitSha1XCommitsBack(int xCommitsBack)
        {
            var command = string.Format("rev-parse Head~{0}", xCommitsBack).ToString();
            return RunGitCommand(command, this.vstsgitRepoDirectory);
        } 

        private string RunGitCommand(string command, string workingDirectory)
        {
            var commandResponse = string.Empty;
            var proc = new Process {
                StartInfo = new ProcessStartInfo {
                    WorkingDirectory = workingDirectory,
                    FileName = "git",
                    Arguments = command,
                    UseShellExecute = false,
                    RedirectStandardOutput = true,
                    CreateNoWindow = true
                }
            };
            proc.Start();
            while (!proc.StandardOutput.EndOfStream) {
                commandResponse += proc.StandardOutput.ReadLine();
            }
            return commandResponse;
        }
    }
}
