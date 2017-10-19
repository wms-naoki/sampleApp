class TasksController < ApplicationController
  before_action :signed_in_user, only: [:create, :destroy]
  #before_action :correct_user,   only: :destroy

  def create
    @project = Project.find(params[:project_id])
    @task = @project.tasks.build(task_params)
    @task.project_id = @project.id
    if @task.save
      flash[:success] = "タスクを追加しました"
      redirect_to project_path(@project)
    else
      @feed_items = []
      render 'static_pages/home'
    end
  end

  def edit
    @project = Project.find(params[:project_id])
    @task = @project.tasks.find_by(id: params[:id])
  end

  def update
    @project = Project.find(params[:project_id])
    @task = @project.tasks.find_by(id: params[:id])
    respond_to do |format|
      if @task.update(task_params)
        format.html { redirect_to @project, notice: '更新しました' }
        format.js { render :tasks }
      else
        format.html { render action: 'edit' }
        format.js { render :tasks }
      end
    end
  end

  def destroy
    @task = Task.find_by(id: params[:task_id])
    @task.destroy
    @project = Project.find(params[:project_id])
    flash[:success] = "削除"
    redirect_to project_path(@project)
  end

  def start
    @project = Project.find(params[:project_id])
    @task = Task.find_by(id: params[:task_id])
    @task.start
    if @task.save
      flash[:success] = "開始しました"
      redirect_to project_path(@project)
    else
      @feed_items = []
      render 'static_pages/home'
    end
  end

  def finish
    @project = Project.find(params[:project_id])
    @task = Task.find_by(id: params[:task_id])
    @task.finish
    @task.save
    redirect_to root_url
  end

  def sort
    binding.pry
    i = 0
    @task.each do |task|
      # 移動したタスクにはparams[:order]を当てる
      if task.id == params[:task_id].to_i
        task.order = params[:order].to_i
        task.save
        next
      end

      task.order = (i < params[:order].to_i ? i : i + 1)
      task.save
      i += 1
    end

    redirect_to project_path(@project)
  end

  private

    def task_params
      params.require(:task).permit(:content, :id, :status, :planed_time, :actual_time)
    end

    # def correct_user
    #   binding.pry
    #   @task = Task.tasks.find_by(id: params[:task_id])
    #   redirect_to root_url if @task.nil?
    # end
end
