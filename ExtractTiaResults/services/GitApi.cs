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
        private string gitRepoDirectory = string.Empty;
        public GitApi(string gitRepoDir)
        {
            this.gitRepoDirectory = gitRepoDir;
        }
        public Dictionary<string, string> GetCommitSha1s(int buildsBack, int numberOfBuilds)
        {
            var commitShas = new Dictionary<string, string>(); 
            var numberOfCommitsLeft = numberOfBuilds; 
            while(numberOfCommitsLeft > 0)
            {
                var currentCommit = buildsBack-(numberOfBuilds - numberOfCommitsLeft);
                var commitSha1 = this.GetComminSha1XCommitsBack(currentCommit);
                var commitMsg = this.GetCommitMessage(commitSha1);
                commitShas.Add(commitMsg, commitSha1);
                numberOfCommitsLeft--; 
            }
            return commitShas;
        }
    
        private string GetCommitMessage(string commitId)
        {
            var commitSha1 = string.Empty;
            var proc = new Process {
                StartInfo = new ProcessStartInfo {
                    WorkingDirectory = this.gitRepoDirectory,
                    FileName = "git",
                    Arguments = string.Format("show -s --oneline {0}", commitId).ToString(),
                    UseShellExecute = false,
                    RedirectStandardOutput = true,
                    CreateNoWindow = true
                }
            };
            proc.Start();
            while (!proc.StandardOutput.EndOfStream) {
                commitSha1 += proc.StandardOutput.ReadLine();
            }
            return commitSha1;
        } 
        
        private string GetComminSha1XCommitsBack(int xCommitsBack)
        {
            var commitSha1 = string.Empty;
            var proc = new Process {
                StartInfo = new ProcessStartInfo {
                    WorkingDirectory = this.gitRepoDirectory,
                    FileName = "git",
                    Arguments = string.Format("rev-parse Head~{0}", xCommitsBack).ToString(),
                    UseShellExecute = false,
                    RedirectStandardOutput = true,
                    CreateNoWindow = true
                }
            };
            proc.Start();
            while (!proc.StandardOutput.EndOfStream) {
                commitSha1 += proc.StandardOutput.ReadLine();
            }
            return commitSha1;
        } 
    }
}
