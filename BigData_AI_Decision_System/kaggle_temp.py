# This Python 3 environment comes with many helpful analytics libraries installed
# It is defined by the kaggle/python Docker image: https://github.com/kaggle/docker-python
# For example, here's several helpful packages to load

import numpy as np # linear algebra
import pandas as pd # data processing, CSV file I/O (e.g. pd.read_csv)
import json
from datetime import datetime

# Input data files are available in the read-only "../input/" directory
# For example, running this (by clicking run or pressing Shift+Enter) will list all files under the input directory

# This file connects to GCP BigQuery AI and runs all SQL suites for creating and using data
# Tested to work E2E with real connection and data (to satisfy all the requirements for the contest)
# Normally this SQL AI Engine will be used within the rest of the EWS System Arhcitecture

import os
for dirname, _, filenames in os.walk('/kaggle/input'):
    for filename in filenames:
        print(os.path.join(dirname, filename))

# You can write up to 20GB to the current directory (/kaggle/working/) that gets preserved as output when you create a version using "Save & Run All" 
# You can also write temporary files to /kaggle/temp/, but they won't be saved outside of the current session

from google.cloud import bigquery

base_path = "/kaggle/input/sqldata19/"

# Create output directory (Kaggle working directory)
output_dir = '/kaggle/working'
os.makedirs(output_dir, exist_ok=True)

# ========== CONFIG ==========
CONFIG = {
    "project_id": "my-project-1521612101168",
    "dataset_id": "climate_ai",
    "sql_files": {
        "create": f"{base_path}create.sql",
        "mock_data": f"{base_path}mock_data_generator.sql",
        "ml_models": f"{base_path}create_ml_models.sql",
        "views": f"{base_path}views.sql",        
        "pipeline": f"{base_path}optimized_pipeline.sql",
        "alerts_sink": f"{base_path}alerts_sink.sql",
        "alerts": f"{base_path}alerting.sql",
        "select": f"{base_path}select.sql",
        "checks": f"{base_path}optimized_pipeline_checks.sql",
        "earth_ai": f"{base_path}earthAI.sql",
        "sensors": f"{base_path}mobile_sensor_routing.sql",
        "teams": f"{base_path}emergency_team_routing.sql"
    }
}

# ========== INIT ==========
client = bigquery.Client(project=CONFIG["project_id"])
dataset_ref = f"{CONFIG['project_id']}.{CONFIG['dataset_id']}"

# Initialize execution log
execution_log = []
results_data = []

def run_sql_file(path, label):
    print(f"\n🔧 Running {label} script: {path}")
    execution_start = datetime.now()
    
    try:
        with open(path, "r") as f:
            query = f.read()
        
        job = client.query(query)
        result = job.result()  # Wait for completion
        
        execution_end = datetime.now()
        execution_time = (execution_end - execution_start).total_seconds()
        
        # Log execution details
        log_entry = {
            "script": label,
            "file_path": path,
            "status": "SUCCESS",
            "execution_time_seconds": execution_time,
            "timestamp": execution_start.isoformat(),
            "rows_processed": result.total_rows if hasattr(result, 'total_rows') else 0
        }
        execution_log.append(log_entry)
        
        # Try to collect sample results for analysis scripts
        if label in ["Analytics & Forecasting", "Mobile Sensors Routing", "Emergency Teams Routing"]:
            try:
                # Convert results to list for storage
                sample_results = []
                for row in list(result)[:100]:  # Get first 100 rows
                    sample_results.append(dict(row))
                
                results_data.append({
                    "script": label,
                    "sample_data": sample_results,
                    "total_rows": len(sample_results)
                })
                
                print(f"✅ {label} completed successfully. Processed {result.total_rows} rows, saved {len(sample_results)} sample rows.")
            except Exception as sample_error:
                print(f"✅ {label} completed successfully. (Could not extract sample data: {sample_error})")
        else:
            print(f"✅ {label} completed successfully.")
            
    except Exception as e:
        execution_end = datetime.now()
        execution_time = (execution_end - execution_start).total_seconds()
        
        log_entry = {
            "script": label,
            "file_path": path,
            "status": "ERROR",
            "execution_time_seconds": execution_time,
            "timestamp": execution_start.isoformat(),
            "error_message": str(e)
        }
        execution_log.append(log_entry)
        print(f"❌ Error in {label}: {e}")

def save_execution_results():
    """Save all execution results and logs to output files"""
    print(f"\n📁 Saving execution results to {output_dir}")
    
    # 1. Save execution log as CSV
    log_df = pd.DataFrame(execution_log)
    log_filename = os.path.join(output_dir, 'sql_execution_log.csv')
    log_df.to_csv(log_filename, index=False)
    print(f"✅ Saved execution log: {log_filename}")
    
    # 2. Save execution summary
    successful_scripts = len([log for log in execution_log if log['status'] == 'SUCCESS'])
    failed_scripts = len([log for log in execution_log if log['status'] == 'ERROR'])
    total_execution_time = sum([log['execution_time_seconds'] for log in execution_log])
    
    summary = {
        "pipeline_execution_summary": {
            "total_scripts": len(execution_log),
            "successful_scripts": successful_scripts,
            "failed_scripts": failed_scripts,
            "total_execution_time_seconds": total_execution_time,
            "execution_timestamp": datetime.now().isoformat()
        },
        "script_results": execution_log,
        "sample_data_collected": len(results_data)
    }
    
    summary_filename = os.path.join(output_dir, 'pipeline_execution_summary.json')
    with open(summary_filename, 'w') as f:
        json.dump(summary, f, indent=2, default=str)
    print(f"✅ Saved execution summary: {summary_filename}")
    
    # 3. Save sample results data if available
    if results_data:
        for result_set in results_data:
            script_name = result_set['script'].lower().replace(' ', '_').replace('&', 'and')
            result_filename = os.path.join(output_dir, f'{script_name}_sample_results.json')
            with open(result_filename, 'w') as f:
                json.dump(result_set, f, indent=2, default=str)
            print(f"✅ Saved sample results: {result_filename}")
    
    # 4. Generate comprehensive report
    report = f"""
CLIMATE AI BIGQUERY PIPELINE EXECUTION REPORT
============================================
Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}

EXECUTION SUMMARY:
- Total scripts executed: {len(execution_log)}
- Successful executions: {successful_scripts}
- Failed executions: {failed_scripts}
- Total execution time: {total_execution_time:.2f} seconds

SCRIPT EXECUTION DETAILS:
"""
    
    for log in execution_log:
        status_icon = "✅" if log['status'] == 'SUCCESS' else "❌"
        report += f"{status_icon} {log['script']}: {log['status']} ({log['execution_time_seconds']:.2f}s)\n"
    
    if failed_scripts > 0:
        report += "\nERROR DETAILS:\n"
        for log in execution_log:
            if log['status'] == 'ERROR':
                report += f"- {log['script']}: {log.get('error_message', 'Unknown error')}\n"
    
    report += f"""

SAMPLE DATA COLLECTED:
- Analysis scripts with sample data: {len(results_data)}

OUTPUT FILES GENERATED:
- sql_execution_log.csv: Detailed execution log
- pipeline_execution_summary.json: Complete execution summary
- *_sample_results.json: Sample data from analysis scripts
- pipeline_execution_report.txt: This comprehensive report

PIPELINE STATUS: {'COMPLETED WITH ERRORS' if failed_scripts > 0 else 'COMPLETED SUCCESSFULLY'}
"""
    
    report_filename = os.path.join(output_dir, 'pipeline_execution_report.txt')
    with open(report_filename, 'w') as f:
        f.write(report)
    print(f"✅ Saved execution report: {report_filename}")
    
    # Print summary to console
    print(f"\n📊 PIPELINE EXECUTION SUMMARY:")
    print(f"   📈 Scripts executed: {len(execution_log)}")
    print(f"   ✅ Successful: {successful_scripts}")
    print(f"   ❌ Failed: {failed_scripts}")
    print(f"   ⏱️  Total time: {total_execution_time:.2f} seconds")
    print(f"   📁 Output files saved to: {output_dir}")
    
    # List all output files
    output_files = [f for f in os.listdir(output_dir) if f.endswith(('.csv', '.json', '.txt'))]
    print(f"\n📋 OUTPUT FILES ({len(output_files)} total):")
    for i, filename in enumerate(sorted(output_files), 1):
        file_path = os.path.join(output_dir, filename)
        file_size = os.path.getsize(file_path)
        print(f"   {i:2d}. {filename:<40} ({file_size:,} bytes)")
    
    return summary

# ========== EXECUTION ==========
if __name__ == "__main__":
    print("🚀 Starting Climate AI BigQuery pipeline...")
    print(f"📁 Output directory: {output_dir}")
    print(f"🔧 Project: {CONFIG['project_id']}")
    print(f"📊 Dataset: {CONFIG['dataset_id']}")

    # Step 1: Create schema
    run_sql_file(CONFIG["sql_files"]["create"], "Schema Creation")

    # Step 2: Populate mock data
    run_sql_file(CONFIG["sql_files"]["mock_data"], "Mock Data Population")

    # Step 3: Create ML Models
    run_sql_file(CONFIG["sql_files"]["ml_models"], "Create ML Models")

    # Step 4: Create views
    run_sql_file(CONFIG["sql_files"]["views"], "Views Creation")

    # Step 5: Run pipeline
    run_sql_file(CONFIG["sql_files"]["pipeline"], "Optimized Pipeline View")

    # Step 6: Run analytics and forecasting
    run_sql_file(CONFIG["sql_files"]["select"], "Analytics & Forecasting")
    
    # Step 7: Install alert sink
    run_sql_file(CONFIG["sql_files"]["alerts_sink"], "Alert Sink Setup")

    # Step 8: Install alerts
    run_sql_file(CONFIG["sql_files"]["alerts"], "Alerts Setup")

    # Step 9: Run analytics and forecasting
    run_sql_file(CONFIG["sql_files"]["checks"], "Optimized Pipeline Checks Decision Engine")

    # Step 10: Ingest Earth AI metadata (or samples)
    run_sql_file(CONFIG["sql_files"]["earth_ai"], "Earth Engine Metadata")
    
    # Step 11: Calculate the needs for mobile data acquisition sensors routing
    run_sql_file(CONFIG["sql_files"]["sensors"], "Mobile Sensors Routing")
    
    # Step 12: Calculate the needs for emergency teams routing
    run_sql_file(CONFIG["sql_files"]["teams"], "Emergency Teams Routing")
    
    print("\n🏁 Pipeline execution completed.")
    
    # Save all results to output files
    final_summary = save_execution_results()
    
    print(f"\n🎯 SUBMISSION READY:")
    print(f"   📊 All SQL scripts executed and logged")
    print(f"   📁 Results saved to {output_dir}")
    print(f"   📈 Execution data available for analysis")
    print(f"   🔍 Check output files for detailed results")
