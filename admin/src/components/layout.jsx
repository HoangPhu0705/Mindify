import React from "react";
import { Outlet } from "react-router-dom";
import Sidebar from "./sidebar";
import Header from "./header";
// perform layout of dashboard
function Layout(){
    return <div className="flex flex-row bg-neural-100 h-screen w-screen overflow-hidden">
        <div className=""><Sidebar /></div>
        <div className="flex flex-col flex-1">
             <Header/>
            <div className="flex-1 p-4 min-h-0 overflow-auto">{<Outlet/>}</div>

        </div>
    </div>
}

export default Layout