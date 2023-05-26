#!/bin/bash

terraform import google_iam_workload_identity_pool.omgd_wi_pool projects/tpl-redux-staging/locations/global/workloadIdentityPools/tpl-redux-staging-ghac-wip
terraform import google_iam_workload_identity_pool_provider.omgd_wip_provider projects/tpl-redux-staging/locations/global/workloadIdentityPools/tpl-redux-staging-ghac-wip/providers/tpl-redux-staging-ghac-wipp
terraform import google_service_account.sa projects/tpl-redux-staging/serviceAccounts/omgd-tpl-redux-staging-sa@tpl-redux-staging.iam.gserviceaccount.com

terraform refresh

