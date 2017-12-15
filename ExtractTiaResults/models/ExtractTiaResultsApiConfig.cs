using System;

namespace ExtractTiaResults.Models 
{
    public class ExtractTiaResultsApiConfig
    {
        public string gitHubRepoLocalSourcePath { get; set; }         
        public string vstsRepoLocalSourcePathRepo { get; set; }         
        public int vstsTiaBuildId { get; set; } 
        public int vstsRetestAllBuildId { get; set; } 
        public DateTime BuildsAfter { get; set; }
        public string VstsRepoName {get; set; }
    }
}