## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation, either version 3 of the License, or
## (at your option) any later version.

## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.

## You should have received a copy of the GNU General Public License
## along with this program.  If not, see <http://www.gnu.org/licenses/>.

module ObJulia

function babel_run_and_store(mod::Module, src_file, out_file, use_error_pane::Bool, mirror_to_repl::Bool)
    open(out_file, "w+") do _io
        io = IOContext(_io, :limit => true, :module => mod, :color => true)
        result = try
            Core.include(mod, src_file)
        catch err
            flush(_io)
            rethrow()
        end
        Base.invokelatest() do
            for (imgtype, ext) ∈ [("image/png", ".png"), ("image/svg+xml", ".svg")]
                if showable(imgtype, result)
                    tmp = tempname() * ext
                    open(tmp, "w+") do io
                        show(io, imgtype, result) # Save the image to disk
                    end
                    println(io, "[[file:$tmp]]") # print out an org-link to the saved image
                    result = nothing
                end
            end
            isnothing(result) || show(io, "text/plain", result)
        end
    end
    println()
    @info "ob-julia evaluated in module $mod\n"*read(out_file, String)
end

end
