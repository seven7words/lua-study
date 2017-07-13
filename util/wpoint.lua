-- @Author: woopqww111
-- @Date:   2017-07-12 14:49:53
-- @Last Modified by:   woopqww111
-- @Last Modified time: 2017-07-12 15:03:05
local p = {}
function P.get_direction(fx,fy,tx,ty)
	if fx>tx then
		--左方向
		if fy>ty then return 7
		elseif fy<ty then return 1
		else return 4 end
	elseif fx<tx then
		--右方向
		if fy > ty then return 9
		elseif fy<ty then return 3
		else return 6 end
	else
		if fy>ty then return 8
		elseif fy<ty then return 2
		else return 5 end
	end
end
return P