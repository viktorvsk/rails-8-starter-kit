class TodosController < ApplicationController
  before_action :set_todo, only: [ :edit, :update, :destroy, :toggle ]

  def index
    @todos = Todo.by_created
    @todo = Todo.new
  end

  def create
    @todo = Todo.new(todo_params)
    if @todo.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to todos_path }
      end
    else
      @todos = Todo.by_created
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace("todo_form", partial: "todos/form", locals: { todo: @todo }) }
        format.html { render :index, status: :unprocessable_entity }
      end
    end
  end

  def edit
  end

  def update
    if @todo.update(todo_params)
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to todos_path }
      end
    else
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace(dom_id(@todo), partial: "todos/todo", locals: { todo: @todo }) }
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @todo.destroy
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to todos_path }
    end
  end

  def toggle
    @todo.update(completed: !@todo.completed)
    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.replace(dom_id(@todo), partial: "todos/todo", locals: { todo: @todo }) }
      format.html { redirect_to todos_path }
    end
  end

  private

  def set_todo
    @todo = Todo.find(params[:id])
  end

  def todo_params
    params.require(:todo).permit(:title)
  end
end
