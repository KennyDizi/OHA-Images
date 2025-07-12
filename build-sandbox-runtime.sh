cd coreservices && poetry run python3 openhands/runtime/utils/runtime_build.py \
    --base_image nikolaik/python-nodejs:python3.13-nodejs24 \
    --build_folder containers/runtime