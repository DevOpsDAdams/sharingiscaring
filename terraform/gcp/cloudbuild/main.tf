provider "google" {
    project = "an-project-for-me"
    region = "us-central1"
}

resource "google_cloudbuild_trigger" "dadams_trigger" {
  trigger_template {
      branch_name = "master"
      repo_name = "dadamspublicrepo"
  }

    build {
        step {
            name = "gcr.io/cloud-builders/gsutil"
            args = ["cp", "gs://mybucket/remotefile.zip", "localfile.zip"]
            timeout = "120s"
        }
        source {
            storage_source {
                bucket = "dadamsbucket"
                object = "test.tgz"
            }
        }
    }
}
