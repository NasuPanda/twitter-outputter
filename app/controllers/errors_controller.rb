class ErrorsController < ActionController::Base
  layout 'application'

  rescue_from Twitter::Error::Unauthorized, with: :render_401
  rescue_from ActiveRecord::RecordNotFound, with: :render_404
  rescue_from ActionController::RoutingError, with: :render_404
  rescue_from StandardError, with: :render_500

  # 401 Twitter Unauthorized Error
  def render_401(exception = nil)
    if exception
      logger.info "Rendering 401 with exception: #{exception.message}"
    end
    render template: 'errors/error_401', status: 401, layout: 'application'
  end

  # 404 Not Found Error
  def render_404(exception = nil)
    if exception
      logger.info "Rendering 404 with exception: #{exception.message}"
    end
    render template: 'errors/error_404', status: 404, layout: 'application'
  end

  # 500 Internal Server Error
  def render_500(exception = nil)
    if exception
      logger.info "Rendering 500 with exception: #{exception.message}"
    end
    render template: 'errors/error_500', status: 500, layout: 'application'
  end

  def show
    raise request.env['action_dispatch.exception']
  end
end