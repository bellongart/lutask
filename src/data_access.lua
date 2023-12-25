---------------
-- Database connection
--  @package   luatask
--  @filename  data_access.lua
--  @version   1.0
--  @author    José Bello
--  @date      jue 21 dic 2023 14:01:42 -04
---------------


local data_access = class('data_access')
db = require('lib.database.database');

--- Get all instaces from database
-- @function get_all
-- @treturn table all records in table formart
function data_access:get_all()
	db:open()
	local sql = 'select * from tasks'
	-- este método retorna todas las filas en una tabla
	local results = db:get_rows(sql)
	db:close()
	return results
end

--- Generate a query with filter
-- @function generic_query
-- @treturn table result in a table
local function generic_query(query)
	db:open()
	local sql = 'select * from tasks where status=%s'
	-- este método retorna todas las filas en una tabla
	local results = db:get_rows(sql, query)
	db:close()
	return results
end

--- Get all tasks completed
-- @function get_completed
-- @treturn table all records in table formart
function data_access:get_completed()
	return generic_query(1)
end

--- Get all tasks NOT completed
-- @function get_uncompleted
-- @treturn table all records in table formart
function data_access:get_uncompleted()
	return generic_query(0)
end

--- Delete a task
-- @function delete
-- @treturn bool
function data_access:delete(id)
	db:open()
	db:begin()
	local sql = 'delete from tasks where id_task=%s'
	local ok, err = db:execute(sql, id)

	if (not ok) then
		print(err)
		db:rollback()
		db:close()
		return false, err
	end

	db:commit()
	db:close()
	return true
end

--- Search a especify task by id
-- @function get_by_id
-- @param id row id to filter the result
-- @treturn table data row in a table with a format key=>value
function data_access:get_by_id(id)
	db:open()
	local sql = ('select * from tasks where id_task=%d'):format(id)
	local r

	local result, err = db:get_rows(sql)
	if (not result) then
		print(err)
		return false, err
	end

	for _, column in ipairs(result) do
		r = {
			id 			= column.id_task,
			name 		= column.name,
			descr 	= column.description,
			status	= column.status
		}
	end

	db:close()
	return r
end

--- Modificate a attribute or several attributes of the task
-- @param statement SQL statement to do the query
-- @function modify
-- @treturn int task id
function data_access:modify(statement)
	-- body
	db:open()
	db:begin()

	local ok, err = db:execute(statement)
	if (not ok) then
		for _,k in ipairs(err) do
			print(_, k)
		end
		db:rollback()
		db:close()
		return false, err
	end
	db:commit()
	-- get id of the last task added
	local task_id =	db:get_var('select id_task from tasks order by id_task desc limit 1')

	db:close()
-- Close database connection
	return task_id
end

--- Add a new task
-- @function add
-- @param values table with values: name and description
-- @return id task added
function data_access:add(values)
	local sql = ([[
			insert into	tasks (name, description, status) values ("%s", "%s", 0)
		]]):format(values[1], values[2])
	
	return self:modify(sql)
end

--- Update a task
-- @function update
-- @param values table with values: name and description
-- @return id task added
function data_access:update(values)
	local sql = ([[
		update tasks set description="%s" where id_task=%s
	]]):format(values[1], values[2], values[3])
	
	return self:modify(sql)
end

--- Mark a task as completed
-- @function completed
-- @param id id of the task to mark as completed
-- @return id task marked as complete
function data_access:completed(id)
	local sql = ([[
		update tasks set status=1 where id_task=%s
	]]):format(id)

	return self:modify(sql)
end

--- Mark a task as uncompleted
-- @function uncompleted
-- @param id id of the task to mark as uncompleted
-- @return id task marked as uncomplete
function data_access:uncompleted(id)
	local sql = ([[
		update tasks set status=0 where id_task=%s
	]]):format(id)

	return self:modify(sql)
end

return data_access