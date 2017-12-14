class TasksController < ApplicationController
  before_action :signed_in_user, only: [:create, :destroy]
  before_action :set_project
  #before_action :correct_user,   only: :destroy
  before_action :set_tasks, only: [:sort, :calculate]

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
    format.js { render :success }
  end

  MAX_TIME = 300

  def calculate
    # task_times = @task.order(:order).each_with_object([]) do |task, task_times|
    task_times = @tasks.each_with_object([]) do |task, task_times|
      #binding.pry
      total_last_time = task_times.present? ? task_times.last.sum { |task_time| task_time[:time] } : 0
      # 当日の合計が上限に達している場合、翌日以降に追加する
      if [0, MAX_TIME].include?(total_last_time)
        add_div_mod_times(task.id, task.planed_time, task_times)
      # 当日の合計が上限に達していない場合、当日に追加する
      else
        # タスクの時間を全部追加すると上限を超える場合
        if MAX_TIME < total_last_time + task.planed_time
          # 超えない分だけ当日に追加し、超える分は翌日以降に追加する
          this_time = MAX_TIME - total_last_time
          task_times.last << { id: task.id, time: this_time }
          add_div_mod_times(task.id, task.planed_time - this_time, task_times )
        # 上限を超えない場合
        else
          # 当日に追加する
          task_times.last << { id: task.id, time: task.planed_time }
        end
      end
      task_timees = task_times.zip(@project.start_date.business_dates(task_times.size))
      Daily.destroy_all(task_id: @tasks.map(&:id))
      task_timees.each do |task_times, date|
        task_times.each do |task_time|
          daily = Daily.create(the_date: date, task_id: task_time[:id])
          daily.planed_time = task_time[:time]
          daily.save
        end
      end
    end
    redirect_to project_path(@project)
  end

  private
  def task_params
    params.require(:task).permit(:content, :id, :status, :planed_time, :actual_time, :user_id)
  end

  def set_project
    @project = Project.find(params[:project_id])
  end

  def set_tasks
    @tasks = @project.tasks.order(:order)
  end

  def add_div_mod_times(task_id, planed_time, task_times)
    div, mod = planed_time.divmod(MAX_TIME)
    div.times { |i| task_times << [{ id: task_id, time: MAX_TIME }] }
    task_times << [{ id: task_id, time: mod }] unless mod.zero?
  end
end
