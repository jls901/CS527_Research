using System;

namespace ExtractTiaResults.Models
{
    public class Build 
    {
        public int id { get; set; }
        public string buildNumber { get; set; }     
        public string status { get; set; }
        public string result { get; set; }
        public string queueTime  { get; set; }
        public string startTime { get; set; }
        public string finishTime { get; set; }
        public string sourceVersion { get; set; }
        public string uri { get; set; }
        public int commitLabel { get; set; }
        public TestRun testRun { get; set; }
    }
}