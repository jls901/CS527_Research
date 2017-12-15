using System;

namespace ExtractTiaResults.Models
{
    public class TestResults
    {
        public string GitHubHash { get; set; }
        public string MetaInfo { get; set; }
        public string VstsHash { get; set; }
        public DateTime StartTime  { get; set; }
        public DateTime EndTime  { get; set; }
        public TimeSpan Runtime { get; set; }
        public int TotalTests { get; set; }
        public int NumberOfUnAnalyzedTests { get; set; }
        public int NumberofTestsPassed { get; set; }
        public int NumberOfTestsFailed { get; set; }
        public int NumberOfTestsSkipped { get; set; }
    }
}