using System;
using System.Collections.Generic;
using ExtractTiaResults.Models;

namespace ExtractTiaResults.models
{
    public class ComparisonResultsModel
    {
        public ComparisonResultsModel(TestResults tiaTestResult, 
                                      TestResults retestAllTestResult, 
                                      TestResults ekstaziSharpTestResult, 
                                      string commitHash)
        {
            this.TiaGitHubHash = tiaTestResult.GitHubHash;
            this.TiaMetaInfo = tiaTestResult.MetaInfo;
            this.TiaVstsHash = tiaTestResult.VstsHash;
            this.TiaRuntime = tiaTestResult.Runtime.TotalSeconds;
            this.TiaTotalTests = tiaTestResult.TotalTests;
            this.TiaNumberofTestsPassed = tiaTestResult.NumberofTestsPassed;
            this.TiaNumberOfTestsSkipped = tiaTestResult.NumberOfTestsSkipped;
            this.TiaNumberOfTestsFailed = tiaTestResult.NumberOfTestsFailed;
            this.TiaNumberOfUnAnalyzedTests = tiaTestResult.NumberOfUnAnalyzedTests;
            this.TiaTotalNumberOfTestRun = tiaTestResult.NumberOfTestsFailed + tiaTestResult.NumberofTestsPassed;

            this.RetestAllGitHubHash = retestAllTestResult.GitHubHash;
            this.RetestAllMetaInfo = retestAllTestResult.MetaInfo;
            this.RetestAllVstsHash = retestAllTestResult.VstsHash;
            this.RetestAllRuntime = retestAllTestResult.Runtime.TotalSeconds;
            this.RetestAllTotalTests = retestAllTestResult.TotalTests;
            this.RetestAllNumberofTestsPassed = retestAllTestResult.NumberofTestsPassed;
            this.RetestAllNumberOfTestsSkipped = retestAllTestResult.NumberOfTestsSkipped;
            this.RetestAllNumberOfTestsFailed = retestAllTestResult.NumberOfTestsFailed;
            this.RetestAllNumberOfUnAnalyzedTests = retestAllTestResult.NumberOfUnAnalyzedTests;
            this.RetestAllTotalNumberOfTestRun = retestAllTestResult.NumberOfTestsFailed +retestAllTestResult.NumberofTestsPassed;

            this.ESharpGitHubHash = ekstaziSharpTestResult.GitHubHash;
            this.ESharpMetaInfo = ekstaziSharpTestResult.MetaInfo;
            this.ESharpVstsHash = ekstaziSharpTestResult.VstsHash;
            this.ESharpRuntime = ekstaziSharpTestResult.Runtime.TotalSeconds;
            this.ESharpTotalTests = ekstaziSharpTestResult.TotalTests;
            this.ESharpNumberofTestsPassed = ekstaziSharpTestResult.NumberofTestsPassed;
            this.ESharpNumberOfTestsSkipped = ekstaziSharpTestResult.NumberOfTestsSkipped;
            this.ESharpNumberOfTestsFailed = ekstaziSharpTestResult.NumberOfTestsFailed;
            this.ESharpNumberOfUnAnalyzedTests = ekstaziSharpTestResult.NumberOfUnAnalyzedTests;
            this.ESharpTotalNumberOfTestRun = ekstaziSharpTestResult.NumberOfTestsFailed + ekstaziSharpTestResult.NumberofTestsPassed;
        }

        public string TiaGitHubHash { get; set; }
        public string TiaMetaInfo { get; set; }
        public string TiaVstsHash { get; set; }
        public double TiaRuntime { get; set; }
        public int TiaTotalTests { get; set; }
        public int TiaNumberOfUnAnalyzedTests { get; set; }
        public int TiaNumberofTestsPassed { get; set; }
        public int TiaNumberOfTestsFailed { get; set; }
        public int TiaNumberOfTestsSkipped { get; set; }
        public int TiaTotalNumberOfTestRun { get; set; }
        public double TiaPercentageOfTestsRun { 
            get
            {
                return (double)this.TiaTotalNumberOfTestRun / (double)TiaTotalTests;
            }
        }

        public string RetestAllGitHubHash { get; set; }
        public string RetestAllMetaInfo { get; set; }
        public string RetestAllVstsHash { get; set; }
        public double RetestAllRuntime { get; set; }
        public int RetestAllTotalTests { get; set; }
        public int RetestAllNumberOfUnAnalyzedTests { get; set; }
        public int RetestAllNumberofTestsPassed { get; set; }
        public int RetestAllNumberOfTestsFailed { get; set; }
        public int RetestAllNumberOfTestsSkipped { get; set; }
        public int RetestAllTotalNumberOfTestRun { get; set; }
        public double RetestAllPercentageOfTestsRun { 
            get
            {
                return (double)this.RetestAllTotalNumberOfTestRun / (double)RetestAllTotalTests;
            }
        }

        public string ESharpGitHubHash { get; set; }
        public string ESharpMetaInfo { get; set; }
        public string ESharpVstsHash { get; set; }
        public double ESharpRuntime { get; set; }
        public int ESharpTotalTests { get; set; }
        public int ESharpNumberOfUnAnalyzedTests { get; set; }
        public int ESharpNumberofTestsPassed { get; set; }
        public int ESharpNumberOfTestsFailed { get; set; }
        public int ESharpNumberOfTestsSkipped { get; set; }
        public int ESharpTotalNumberOfTestRun { get; set; }
        public double ESharpPercentageOfTestsRun { 
            get
            {
                return (double)this.ESharpTotalNumberOfTestRun / (double)ESharpTotalTests;
            }
        }
    }
}