function delay = gfb_delay_clear_state(delay)
%GFB_DELAY_CLEAR_STATE  Clear delay lines
%   Usage: delay = gfb_delay_clear_state(delay)
%
%   Input parameters:
%     delay : A `gfb_delay` structure as returned by |gfb_delay_new|_
%
%   `gfb_delay_clear_state(delay)` returns a copy of *delay* with cleared
%   delay lines.

% copyright: Universitaet Oldenburg
% author   : tp
% date     : Jan 2002, Nov 2006

delay.memory = zeros(size(delay.memory));

