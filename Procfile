web: bundle exec puma -t 5:5 -p ${PORT:-3000} -e ${RACK_ENV:-production}
worker: bundle exec shoryuken -r ./workers/download_images_worker.rb -C ./workers/shoryuken.yml
