---------------
--  @package   luatask
--  @filename  cmd.lua
--  @version   1.0
--  @author    José Bello
--  @date      jue 21 dic 2023 14:01:42 -04
---------------

local cmd = class('cmd')
local task = require('src.data_access')
local version = '1.0'

local usage = [[
lutask, a task manager from the terminal v]]..version..[[

 Invocation:
  ./lutask <command> <arguments...>

 Commnads:
   list     - show tasks list
   details  - show all details for a specify task
   add      - add a new task
   update   - update description of a task
   check    - mark a task as completed
   uncheck  - changes the status of a task from complete to incomplete
   delete   - delete a task

 Examples usage:
   ./lutask list
   ./lutask list completed
   ./lutask list uncompleted
   ./lutask details <id_task>
   ./lutask add "task_name" "optional_description_task"
   ./lutask update <id_task> "new_description"
   ./lutask check <id_task>
   ./lutask uncheck <id_task>
   ./lutask delete <id_task>
]]


--- Show a guide on how to use the command line
-- @function help
function cmd:help()
	print(usage)
	os.exit()
end

--- Print all details of a task
-- @function print_details
local function print_details(task)
		print(
			('ID: %s\n'):format(task.id) ..
			('Name: %s\n'):format(task.name) ..
			('Description: %s\n'):format(task.descr) ..
			('Status: %s\n'):format(task.status)
		)
		return true
end

--- Print a list a task withou details
-- @function print_tasklist
local function print_tasklit(tasks)
	for _,k in ipairs(tasks) do
		print(('%s- %s (%s).'):format(k.id_task,k.name,k.status))
	end
	print('')
	return true
end


local function validations(command, arg1, arg2, arg3)
	if (command == 'add') then
		local result = task:add({arg1, arg2 or ''})
		print('\nNew task Added!')
		print_details(task:get_by_id(result))

	elseif (command == 'list') then
		if (not arg1) then
			print('\nAll tasks:')
			print_tasklit(task:get_all())
			return true
		end
		if ( arg1 and arg1 == 'completed') then
			print('\nList completed task')
			print_tasklit(task:get_completed())
		elseif ( arg1 and arg1 == 'uncompleted' ) then
			print('\nList uncompleted task')
			print_tasklit(task:get_uncompleted())
		end

	elseif (command == 'details') then
		print('\nTask Details:')
		print_details(task:get_by_id(arg1))

	elseif (command == 'check') then
		task:completed(arg1)
		print(('\nTask %s marked as finished!'):format(arg1))
		print_details(task:get_by_id(arg1))

	elseif (command == 'uncheck') then
		task:uncompleted(arg1)
		print(('\nTask %s marked as uncompleted!'):format(arg1))
		print_details(task:get_by_id(arg1))

	elseif (command == 'update') then
		print('\nTask update!')
		task:update({arg2 , arg1})
		print_details(task:get_by_id(arg1))

	elseif (command == 'delete') then
		print('Task delete')
		task:delete(arg1)

	else
		return false, 'Command Not Found!'
	end
	return true
end

function cmd:execute(command, arg1, arg2, arg3)
	local ok, err = validations(command, arg1, arg2, arg3)
	if (ok == false) then
		print(('%s\n'):format(err))
		self:help()
		os.exit()
	end
end

return cmd