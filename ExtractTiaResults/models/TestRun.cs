using System;

namespace ExtractTiaResults.Models
{
    public class TestRun
    {
        public int id { get; set; }
        public int totalTests { get; set; }
        public int passedTests { get; set; }
        public int unanalyzedTests { get; set; }
        public string startedDate { get; set; }
        public string completedDate { get; set; }

        public TimeSpan runTime 
        {
            get
            {
                var startTime = Convert.ToDateTime(this.startedDate);
                var endTime = Convert.ToDateTime(this.completedDate);
                return endTime.Subtract(startTime);
            }
        }
    }
}